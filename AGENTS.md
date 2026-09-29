# Project Rules for Agents

This repository is the **public** Jekyll website for the Geometry and
Mathematical Physics group. Read `README.md` for content editing and
`DEVELOPING.md` for how the site works internally (rendering, includes, build,
deploy, data validation); this file lists the rules to follow when making
changes.

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
- Every `_data/*.yml` file opens with a plain-language comment header for
  non-technical editors (purpose, YAML rules, how to add an entry, fields). Keep
  it accurate: if you change or add a field, update that header too.
- `bin/validate_data.rb` is the machine-checked schema for `_data/*.yml`
  (required/optional fields, types, allowed values, and person cross-references).
  CI runs it and **blocks the deploy on invalid data** (see below). When you
  **change the format** of a data file — add/rename a field, add an allowed value,
  or add a new data file — keep three places in sync, or the change either fails
  CI or silently does nothing:
    1. the data file itself **and its comment header**;
    2. the template that renders it (`_includes/*.html` or the page's `.md`) —
       a new field displays nothing until it is added here;
    3. the schema in `bin/validate_data.rb` (add to `required:`/`optional:`, an
       enum array, or a new per-file block). A new **required** field must also
       be filled in on every existing entry.
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
- Members-only material lives in two sibling repos, never here: the private
  *pages* in `GeomMPhys/geommphys.github.io-private` (overlaid on this theme,
  StatiCrypt-encrypted, then published back into this repo under `/members/`,
  `/news/`, `/meetings/`, `/grants/`, `/certificates/` — those are generated,
  do not hand-edit), and confidential *files* in `GeomMPhys/group-documents`
  (real GitHub auth). See `DEVELOPING.md` → "Private site and internal content".

## Development

- Build/preview with the Docker command in `README.md` (Ruby 3.1 + Bundler
  2.5.23, matching CI), or `bundle exec jekyll serve` with a local toolchain.
- After editing any `_data/*.yml`, run `ruby bin/validate_data.rb` (Ruby stdlib
  only, no bundle needed). It reports schema problems in plain language and is
  what CI enforces: `.github/workflows/validate.yml` runs it on pull requests
  and branch pushes, and `pages.yml` runs it before every build so a bad push to
  `main` fails instead of deploying broken data.
- Keep generated `_site/` out of version control.
- After structural edits, build the site and check that navigation, the
  data-driven pages, people links, and GitHub Pages deployment still work.
