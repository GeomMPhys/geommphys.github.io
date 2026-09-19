# frozen_string_literal: true

# ───────────────────────────────────────────────────────────────────
#  One page per group member, at /people/<id>/.
#
#  Generated rather than written by hand: there are twenty-two people and
#  every field on the page already exists in _data. A folder of twenty-two
#  near-identical .md files would be twenty-two things to forget to update.
#
#  Only the three groups that get a card on the People page are given a
#  page — `visitors` are deliberately not shown there, and a page for
#  someone the site does not otherwise list would be a surprise.
#
#  Everything on the page is derived: the research lines come from
#  research_lines.yml by membership, the papers from publications.yml by
#  author id. The single stored field the design adds is `positions`.
#
#  Nothing else in the site needs a plugin, and CI runs a plain
#  `bundle exec jekyll build`, which loads this automatically.
# ───────────────────────────────────────────────────────────────────

module GeomMPhys
  CARDED_GROUPS = %w[researchers_madrid students_madrid
                     international_collaborators].freeze

  GROUP_LABELS = {
    "researchers_madrid" => "Madrid",
    "students_madrid" => "Madrid",
    "international_collaborators" => "International collaborator",
  }.freeze

  class PersonPage < Jekyll::PageWithoutAFile
    def initialize(site, person, group)
      super(site, site.source, File.join("people", person["id"]), "index.html")

      data["layout"] = "person"
      data["title"] = person["name"]
      data["person_id"] = person["id"]
      data["group_label"] = GROUP_LABELS.fetch(group, "Group member")
      data["description"] =
        if person["research"] && !person["research"].to_s.strip.empty?
          "#{person['name']} — #{person['research']}."
        else
          "#{person['name']}, Geometrical Mathematical Physics Research Group."
        end
    end
  end

  class PersonPageGenerator < Jekyll::Generator
    safe true
    priority :normal

    def generate(site)
      people = site.data["people"]
      return unless people.is_a?(Hash)

      CARDED_GROUPS.each do |group|
        entries = people[group]
        next unless entries.is_a?(Array)

        entries.each do |person|
          next unless person.is_a?(Hash) && person["id"].is_a?(String)
          site.pages << PersonPage.new(site, person, group)
        end
      end
    end
  end
end
