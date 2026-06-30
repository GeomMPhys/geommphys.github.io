# Project Rules for Agents

This repository is the **public** Jekyll website for the Geometry and
Mathematical Physics group. Read `README.md` for the full content model; this
file lists the rules to follow when making changes.

## Site architecture

- Keep it a Jekyll project that builds on GitHub Pages via
  `.github/workflows/pages.yml`.
- The site is **data-driven**: content lives in `_data/*.yml`, and pages are
  thin templates that render it. Prefer editing YAML over writing HTML.
- Reuse `_layouts/` and `_includes/` for repeated structure. Add a new include
  rather than duplicating markup across pages.
- Avoid hand-written standalone HTML pages unless there is a clear Jekyll reason.
- Keep the design restrained, academic, responsive, and accessible. Scope visual
  changes to the existing style system in `assets/css/main.scss` and reuse
  existing classes (`.card`, `.publication`, `.stack`, `.meta`, `.links`, ...).

## Content and data conventions

- Put reusable structured data in `_data/`. Each content type has its own file
  (`research_lines`, `research_visits`, `awards`, `workshops`, `outreach`, ...).
- **Every person in `people.yml` has a stable `id` slug** (lowercase,
  hyphenated). Other data files reference people **by id**, never by retyping
  their name.
- A people reference is either an `id` string (for members/collaborators) or an
  inline `{ name, affiliation }` mapping (for externals not in `people.yml`).
  `research_visits.yml` is id-only and visitors must exist in `people.yml`
  (usually under the `visitors` group); it allows an optional `affiliation`
  override per visit.
- Use ISO dates (`2026-03-12`). Pages derive year headings and ordering from the
  data — do not hand-write year sections.
- Do not invent real people, publications, affiliations, grants, or events. Use
  placeholders only when clearly temporary and never present them as factual
  records. When grouping or describing content involves judgement (e.g.
  assigning people to research lines), flag it as a draft for the group to
  review.
- Keep public content concise and professional.

## Privacy

- Do not commit private Google Sites exports, internal notes, credentials,
  unpublished documents, or any personal data not intended for the public site.
- Keep private material in ignored folders such as `private/`, `internal/`,
  `migration-notes/`, or `google-sites-export/`.
- Do not expose `.agents/`, `.codex/`, local environment files, or generated
  build output (`_site/`).

## Development

- Build/preview with the Docker command in `README.md` (Ruby 3.1 + Bundler
  2.5.23, matching CI), or `bundle exec jekyll serve` with a local toolchain.
- Keep generated `_site/` out of version control.
- After structural edits, build the site and check that navigation, the
  data-driven pages, people links, and GitHub Pages deployment still work.
