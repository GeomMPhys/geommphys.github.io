# frozen_string_literal: true

# ───────────────────────────────────────────────────────────────────
#  One page per research line, at /research-lines/<id>/.
#
#  Same reasoning as _plugins/person_pages.rb: the page is built entirely
#  from research_lines.yml, people.yml and publications.yml, so writing
#  one .md per line would only add files to forget.
#
#  The line's `id` is its address, which is why bin/validate_data.rb
#  requires it to be lowercase-with-hyphens.
# ───────────────────────────────────────────────────────────────────

module GeomMPhys
  class ResearchLinePage < Jekyll::PageWithoutAFile
    def initialize(site, line, index, total)
      super(site, site.source, File.join("research-lines", line["id"]), "index.html")

      data["layout"] = "research-line"
      data["title"] = line["name"]
      data["line_id"] = line["id"]
      data["line_number"] = index
      data["line_total"] = total
      data["description"] =
        if line["description"].is_a?(String) && !line["description"].strip.empty?
          line["description"].split(/(?<=\.)\s/).first.to_s.strip
        else
          "#{line['name']} — a research line of the Geometrical Mathematical Physics Research Group."
        end
    end
  end

  class ResearchLinePageGenerator < Jekyll::Generator
    safe true
    priority :normal

    def generate(site)
      lines = site.data.dig("research_lines", "lines")
      return unless lines.is_a?(Array)

      lines.each_with_index do |line, i|
        next unless line.is_a?(Hash) && line["id"].is_a?(String)
        site.pages << ResearchLinePage.new(site, line, i + 1, lines.size)
      end
    end
  end
end
