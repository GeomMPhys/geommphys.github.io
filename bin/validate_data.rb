#!/usr/bin/env ruby
# frozen_string_literal: true

# ───────────────────────────────────────────────────────────────────
#  Validates the _data/*.yml files against the schema documented in
#  each file's header comment. Run with:  ruby bin/validate_data.rb
#
#  Exits 0 if everything is fine, 1 if there is any error. Errors are
#  written in plain language so a non-technical editor can fix them.
#
#  Uses only the Ruby standard library (yaml + date), so it needs no
#  bundle install and runs in a couple of seconds in CI.
# ───────────────────────────────────────────────────────────────────

require "yaml"
require "date"

DATA_DIR = File.expand_path("../_data", __dir__)

errors = []
def err(errors, file, msg) = errors << "#{file}: #{msg}"

# ── helpers ────────────────────────────────────────────────────────

DATE_RE = /\A\d{4}-\d{2}-\d{2}\z/

# A YYYY-MM-DD field: YAML turns an unquoted 2026-06-09 into a Date;
# a quoted or mistyped one stays a String. Accept both, reject the rest.
def valid_date?(v)
  return true if v.is_a?(Date)
  v.is_a?(String) && v.match?(DATE_RE) && (Date.iso8601(v) rescue false)
end

def blank?(v)
  v.nil? || (v.is_a?(String) && v.strip.empty?)
end

# A flexible outreach date: a full date (Date, or "YYYY-MM-DD"), a year-month
# ("YYYY-MM"), or a year (Integer 2024, or "2024"). Editors write as much as
# they know; unquoted YAML gives us a Date / Integer / String accordingly.
PARTIAL_DATE_RE = /\A\d{4}(-(0[1-9]|1[0-2])(-\d{2})?)?\z/
def valid_outreach_date?(v)
  return true if v.is_a?(Date)
  return v.between?(1900, 2100) if v.is_a?(Integer)
  return false unless v.is_a?(String) && v.match?(PARTIAL_DATE_RE)
  return true if v.length < 10 # year or year-month
  (Date.iso8601(v) rescue false)
end

# Validate one record (a Hash) against a field spec.
#   spec[:required] => { field => type_symbol }
#   spec[:optional] => { field => type_symbol }
# type_symbol is one of the checkers in TYPE_CHECK below, or an Array
# (an enum of allowed values).
TYPE_CHECK = {
  str:  ->(v) { v.is_a?(String) },
  num:  ->(v) { v.is_a?(Numeric) },
  year: ->(v) { v.is_a?(Integer) && v.between?(1900, 2100) },
  date: ->(v) { valid_date?(v) },
  odate: ->(v) { valid_outreach_date?(v) },
  list: ->(v) { v.is_a?(Array) },
  bool: ->(v) { v == true || v == false },
}

def type_ok?(type, value)
  return type.include?(value) if type.is_a?(Array) # enum
  TYPE_CHECK.fetch(type).call(value)
end

def type_desc(type)
  return "one of: #{type.join(', ')}" if type.is_a?(Array)
  {
    str: "text (in quotes)", num: "a number", year: "a 4-digit year",
    date: "a date written YYYY-MM-DD",
    odate: "a year (2024), year-month (2024-05), or full date (2024-05-20)",
    list: "a list", bool: "true or false",
  }.fetch(type)
end

def check_record(errors, file, where, rec, spec)
  unless rec.is_a?(Hash)
    err(errors, file, "#{where} should be a block of `field: value` lines, " \
                      "but it is #{rec.class == Array ? 'a list' : 'a single value'}.")
    return
  end

  known = ((spec[:required] || {}).keys + (spec[:optional] || {}).keys).map(&:to_s)

  (spec[:required] || {}).each do |field, type|
    if !rec.key?(field.to_s)
      err(errors, file, "#{where} is missing the required field `#{field}`.")
    elsif blank?(rec[field.to_s])
      err(errors, file, "#{where} has an empty `#{field}` — fill it in or, " \
                        "if optional, delete the whole line.")
    elsif !type_ok?(type, rec[field.to_s])
      err(errors, file, "#{where}: `#{field}` must be #{type_desc(type)} " \
                        "(got #{rec[field.to_s].inspect}).")
    end
  end

  (spec[:optional] || {}).each do |field, type|
    next unless rec.key?(field.to_s)
    v = rec[field.to_s]
    next if blank?(v) && type != :list # an omitted-but-present empty optional is tolerated
    unless type_ok?(type, v)
      err(errors, file, "#{where}: `#{field}` must be #{type_desc(type)} " \
                        "(got #{v.inspect}).")
    end
  end

  rec.each_key do |field|
    next if known.include?(field)
    err(errors, file, "#{where} has an unknown field `#{field}` — check the " \
                      "spelling (allowed: #{known.join(', ')}).")
  end
end

# Load a YAML file, reporting a friendly parse error instead of crashing.
def load_yaml(errors, path)
  YAML.load_file(path, permitted_classes: [Date, Time], aliases: true)
rescue Psych::SyntaxError => e
  err(errors, File.basename(path),
      "the file is not valid YAML (line #{e.line}): #{e.problem}. " \
      "Common causes: a TAB instead of spaces, wrong indentation, or a " \
      "colon inside unquoted text.")
  nil
end

# Fetch the top-level list under `key`, checking shape.
def top_list(errors, file, doc, key)
  unless doc.is_a?(Hash) && doc.key?(key)
    err(errors, file, "expected a top-level `#{key}:` section.")
    return []
  end
  v = doc[key]
  if v.nil?
    []
  elsif v.is_a?(Array)
    v
  else
    err(errors, file, "`#{key}:` should be a list of `- ` items.")
    []
  end
end

# ── load people.yml first: it is the source of truth for person ids ──

PEOPLE_GROUPS = %w[researchers_madrid students_madrid
                   international_collaborators visitors].freeze

person_ids = {}   # id => group (for existence checks + duplicate detection)
people_doc = load_yaml(errors, File.join(DATA_DIR, "people.yml"))

if people_doc.is_a?(Hash)
  PEOPLE_GROUPS.each do |group|
    next unless people_doc.key?(group)
    list = people_doc[group]
    unless list.is_a?(Array)
      err(errors, "people.yml", "`#{group}:` should be a list of people.")
      next
    end
    list.each_with_index do |rec, i|
      where = "people.yml → #{group} entry ##{i + 1}"
      check_record(errors, "people.yml", where, rec, {
        required: { id: :str, name: :str },
        optional: { photo: :str, role: :str, research: :str, email: :str,
                    website: :str, profiles: :list, arxiv: :bool },
      })
      next unless rec.is_a?(Hash) && rec["id"].is_a?(String)

      id = rec["id"]
      if person_ids.key?(id)
        err(errors, "people.yml", "#{where}: duplicate id `#{id}` " \
                                  "(already used in #{person_ids[id]}).")
      else
        person_ids[id] = group
      end
      unless id.match?(/\A[a-z0-9-]+\z/)
        err(errors, "people.yml", "#{where}: id `#{id}` must be " \
                                  "lowercase-with-hyphens (letters, numbers, -).")
      end

      # profiles: list of { type, label, url }
      next unless rec["profiles"].is_a?(Array)
      rec["profiles"].each_with_index do |p, j|
        check_record(errors, "people.yml", "#{where} → profile ##{j + 1}", p, {
          required: { type: :str, url: :str },
          optional: { label: :str },
        })
      end
    end
  end
  (people_doc.keys - PEOPLE_GROUPS).each do |extra|
    err(errors, "people.yml", "unknown top-level section `#{extra}` " \
                              "(allowed: #{PEOPLE_GROUPS.join(', ')}).")
  end
end

# Report a person reference that does not resolve to a people.yml id.
def check_person_ref(errors, file, where, id, person_ids)
  return if person_ids.key?(id)
  err(errors, file, "#{where}: person `#{id}` is not in people.yml — " \
                    "add them there first, or fix the spelling.")
end

# ── the record-list files ──────────────────────────────────────────

# awards.yml
if (doc = load_yaml(errors, File.join(DATA_DIR, "awards.yml")))
  top_list(errors, "awards.yml", doc, "awards").each_with_index do |rec, i|
    where = "awards.yml entry ##{i + 1}"
    check_record(errors, "awards.yml", where, rec, {
      required: { person: :str, award: :str, year: :year },
      optional: { category: :str },
    })
    check_person_ref(errors, "awards.yml", where, rec["person"], person_ids) if rec.is_a?(Hash) && rec["person"].is_a?(String)
  end
end

# research_visits.yml
if (doc = load_yaml(errors, File.join(DATA_DIR, "research_visits.yml")))
  top_list(errors, "research_visits.yml", doc, "visits").each_with_index do |rec, i|
    where = "research_visits.yml entry ##{i + 1}"
    check_record(errors, "research_visits.yml", where, rec, {
      required: { person: :str, affiliation: :str, arrival: :date, departure: :date },
      optional: { support: :str },
    })
    check_person_ref(errors, "research_visits.yml", where, rec["person"], person_ids) if rec.is_a?(Hash) && rec["person"].is_a?(String)
  end
end

# outreach.yml
OUTREACH_KIND = %w[talk article stand interview video].freeze
OUTREACH_LANG = %w[es en].freeze
if (doc = load_yaml(errors, File.join(DATA_DIR, "outreach.yml")))
  top_list(errors, "outreach.yml", doc, "activities").each_with_index do |rec, i|
    where = "outreach.yml entry ##{i + 1}"
    check_record(errors, "outreach.yml", where, rec, {
      required: { title: :str, people: :list, date: :odate },
      optional: { kind: OUTREACH_KIND, work_title: :str, venue: :str,
                  lang: OUTREACH_LANG, links: :list },
    })
    next unless rec.is_a?(Hash)
    if rec["people"].is_a?(Array)
      rec["people"].each { |id| check_person_ref(errors, "outreach.yml", where, id, person_ids) if id.is_a?(String) }
    end
    if rec["links"].is_a?(Array)
      rec["links"].each_with_index do |lnk, j|
        check_record(errors, "outreach.yml", "#{where} → link ##{j + 1}", lnk, {
          required: { label: :str, url: :str },
        })
      end
    end
  end
end

# research_lines.yml
if (doc = load_yaml(errors, File.join(DATA_DIR, "research_lines.yml")))
  top_list(errors, "research_lines.yml", doc, "lines").each_with_index do |rec, i|
    where = "research_lines.yml entry ##{i + 1}"
    check_record(errors, "research_lines.yml", where, rec, {
      required: { id: :str, name: :str, description: :str, people: :list },
      optional: { keywords: :list },
    })
    next unless rec.is_a?(Hash) && rec["people"].is_a?(Array)
    rec["people"].each { |id| check_person_ref(errors, "research_lines.yml", where, id, person_ids) if id.is_a?(String) }
  end
end

# workshops.yml — organizers are either a person id (String) or { name, affiliation? }
WORKSHOP_TYPE = %w[conference workshop school].freeze
if (doc = load_yaml(errors, File.join(DATA_DIR, "workshops.yml")))
  top_list(errors, "workshops.yml", doc, "events").each_with_index do |rec, i|
    where = "workshops.yml entry ##{i + 1}"
    check_record(errors, "workshops.yml", where, rec, {
      required: { title: :str, type: WORKSHOP_TYPE, start: :date, end: :date,
                  location: :str, organizers: :list },
      optional: { url: :str, description: :str },
    })
    next unless rec.is_a?(Hash) && rec["organizers"].is_a?(Array)
    rec["organizers"].each_with_index do |org, j|
      if org.is_a?(String)
        check_person_ref(errors, "workshops.yml", "#{where} → organizer ##{j + 1}", org, person_ids)
      elsif org.is_a?(Hash)
        check_record(errors, "workshops.yml", "#{where} → organizer ##{j + 1}", org, {
          required: { name: :str }, optional: { affiliation: :str },
        })
      else
        err(errors, "workshops.yml", "#{where} → organizer ##{j + 1}: must be " \
            "either a person id or `{ name: \"...\", affiliation: \"...\" }`.")
      end
    end
  end
end

# seminars.yml — two lists: upcoming + past
if (doc = load_yaml(errors, File.join(DATA_DIR, "seminars.yml")))
  if doc.is_a?(Hash)
    (doc.keys - %w[upcoming past]).each do |extra|
      err(errors, "seminars.yml", "unknown top-level section `#{extra}` (allowed: upcoming, past).")
    end
  end
  %w[upcoming past].each do |section|
    next unless doc.is_a?(Hash) && doc[section].is_a?(Array)
    doc[section].each_with_index do |rec, i|
      check_record(errors, "seminars.yml", "seminars.yml → #{section} entry ##{i + 1}", rec, {
        required: { title: :str, speaker: :str, date: :date },
        optional: { affiliation: :str, time: :str, location: :str, abstract: :str },
      })
    end
  end
end

# research.yml — a top-level list of cards
if (doc = load_yaml(errors, File.join(DATA_DIR, "research.yml")))
  if doc.is_a?(Array)
    doc.each_with_index do |rec, i|
      check_record(errors, "research.yml", "research.yml card ##{i + 1}", rec, {
        required: { title: :str, summary: :str },
        optional: { url: :str, topics: :list },
      })
    end
  else
    err(errors, "research.yml", "expected a top-level list of `- title:` cards.")
  end
end

# network.yml — the map: locations with member ids resolved from people.yml
if (doc = load_yaml(errors, File.join(DATA_DIR, "network.yml")))
  if doc.is_a?(Hash) && doc["center"]
    check_record(errors, "network.yml", "network.yml center", doc["center"], {
      required: { label: :str, x: :num, y: :num }, optional: { subtitle: :str },
    })
  end
  if doc.is_a?(Hash) && doc["locations"].is_a?(Array)
    doc["locations"].each_with_index do |loc, i|
      where = "network.yml location ##{i + 1} (#{loc.is_a?(Hash) ? loc['label'] : '?'})"
      check_record(errors, "network.yml", where, loc, {
        required: { label: :str, subtitle: :str, x: :num, y: :num,
                    curve: :str, members: :list },
        optional: { inset: :bool },
      })
      next unless loc.is_a?(Hash) && loc["members"].is_a?(Array)
      loc["members"].each_with_index do |m, j|
        if m.is_a?(String)
          check_person_ref(errors, "network.yml", "#{where} → member ##{j + 1}", m, person_ids)
        elsif m.is_a?(Hash)
          check_record(errors, "network.yml", "#{where} → member ##{j + 1}", m, {
            required: { name: :str }, optional: { affiliation: :str },
          })
        else
          err(errors, "network.yml", "#{where} → member ##{j + 1}: must be a " \
              "person id or `{ name: \"...\" }`.")
        end
      end
    end
  end
end

# ── files with a fixed shape: just confirm they parse cleanly ───────
#    (navigation.yml, site.yml, contact.yml). These are edited rarely and
#    structurally; a clean YAML parse is enough.
%w[navigation.yml site.yml contact.yml].each do |f|
  load_yaml(errors, File.join(DATA_DIR, f))
end

# ── report ─────────────────────────────────────────────────────────

if errors.empty?
  puts "✓ All _data files are valid."
  exit 0
else
  warn "✗ Found #{errors.size} problem#{'s' if errors.size != 1} in _data:\n\n"
  errors.each { |e| warn "  • #{e}" }
  warn "\nFix the lines above and commit again. " \
       "See the comment at the top of each file for the allowed fields."
  exit 1
end
