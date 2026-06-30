# Geometry and Mathematical Physics Website

Public Jekyll website for the Geometry and Mathematical Physics group, deployed
to GitHub Pages. Content is **data-driven**: most pages are thin templates that
render structured data from `_data/`, so routine updates mean editing YAML, not
HTML.

## How the site is organised

- **Pages** (repository root, Markdown): `index.md`, `people.md`, `research.md`,
  `research-lines.md`, `publications.md`, `research-visits.md`, `seminars.md`,
  `conferences-workshops.md`, `awards-honours.md`, `outreach.md`, `diversity.md`,
  `contact.md`. Most of these just loop over a data file and call an include.
- **Data** (`_data/`): the source of truth for content.
  - `site.yml`, `navigation.yml`, `contact.yml` — site metadata, menu, contact.
  - `people.yml` — everyone, grouped and given a stable `id` (see below).
  - `publications.yml`, `seminars.yml`, `research.yml` — existing content.
  - `research_lines.yml`, `research_visits.yml`, `awards.yml`, `workshops.yml`,
    `outreach.yml` — structured content for the corresponding pages.
- **Templates** (`_layouts/`, `_includes/`): shared structure. Item renderers
  live in `_includes/` (`person-card.html`, `publication.html`, `seminar-item.html`,
  `research-line.html`, `research-visit.html`, `workshop.html`, `outreach-item.html`,
  plus the helpers `person-name.html` and `date-range.html`).
- **Styles**: `assets/css/main.scss`.

## People and the linking convention

Every person in `_data/people.yml` has a stable `id` slug. Other data files
reference people **by that id**, and the templates resolve it to the person's
name (and, on some pages, a link to their card on the People page).

```yaml
researchers_madrid:
  - id: ada-lovelace          # stable slug — referenced from other files
    name: "Ada Lovelace"
    role: "PhD in Mathematics, ..."
    research: "Differential geometry, ..."
    profiles:
      - type: "orcid"         # orcid | scholar | inspire
        label: "ORCID"
        url: "https://orcid.org/0000-0000-0000-0000"
```

Groups in `people.yml`: `researchers_madrid`, `students_madrid`,
`international_collaborators`, and `visitors` (external research visitors, not
shown on the People page).

**Referencing people elsewhere.** A people reference is either:

- a **string** — an `id` in `people.yml` (use this for group members and
  collaborators), or
- an inline **mapping** `{ name: "...", affiliation: "..." }` — for external
  people who are not in `people.yml` (e.g. external workshop co-organizers).

`research_visits.yml` is the exception: it is **id-only** (no inline name), so
every visitor must exist in `people.yml` (typically under `visitors`). It allows
an optional per-visit `affiliation:` override when the visit affiliation differs
from the person's `role`.

## Editing content

### Add a person

Add an entry under the right group in `_data/people.yml`, giving it a unique
`id` (lowercase, hyphenated). Photos go in `assets/images/people/` (lowercase,
hyphenated filenames) and are referenced with `photo:`.

### Add a research line — `_data/research_lines.yml`

```yaml
lines:
  - id: my-line
    name: "My Research Line"
    keywords: ["keyword one", "keyword two"]
    description: "One paragraph describing the line."
    people: [ada-lovelace, alan-turing]   # ids; rendered as links to /people/
```

### Add a research visit — `_data/research_visits.yml`

```yaml
visits:
  - person: ada-lovelace          # id in people.yml (required)
    affiliation: "Host institution, Country"   # optional override
    arrival: 2026-03-12            # ISO dates; the page groups by year
    departure: 2026-03-15
    support: "Funding source"      # optional
```

### Add an award — `_data/awards.yml`

```yaml
awards:
  - person: ada-lovelace          # id
    award: "Name of award"
    category: "PhD scholarship"    # e.g. fellowship / certification
    year: 2026
```

### Add a conference / workshop / school — `_data/workshops.yml`

```yaml
events:
  - title: "Event title"
    type: workshop                 # conference | workshop | school
    start: 2026-07-06              # ISO dates
    end: 2026-07-08
    location: "Place, Country"
    url: "https://..."             # optional
    description: "Optional note."
    organizers:                    # mixed: ids or {name, affiliation}
      - ada-lovelace
      - { name: "External Person", affiliation: "Their University" }
```

### Add an outreach activity — `_data/outreach.yml`

```yaml
activities:
  - title: "Activity title"
    people: [ada-lovelace]         # ids
    kind: talk                     # talk | article | stand | interview | video
    work_title: "Title of the talk/article"   # optional
    venue: "Place or publication"
    date: 2026-05-20               # optional full date
    year: 2026                     # always present (used for grouping)
    lang: es                       # optional
    links:                         # optional
      - { label: "Watch", url: "https://..." }
```

### Publications and seminars

`_data/publications.yml` (`selected:`) groups by `year`; `_data/seminars.yml`
has `upcoming:` and `past:` lists. See existing entries for the shape.

## Local development

Ruby/Bundler can be fiddly to install locally, so the simplest reproducible way
to build is **Docker, using the same stack as CI** (Ruby 3.1, Bundler 2.5.23):

```bash
# Build
docker run --rm \
  -u "$(id -u):$(id -g)" -e HOME=/tmp -e GEM_HOME=/tmp/gems \
  -e PATH="/tmp/gems/bin:/usr/local/bin:/usr/bin:/bin" \
  -v "$PWD":/site -w /site ruby:3.1 \
  bash -c "gem install bundler -v 2.5.23 --no-document && bundle _2.5.23_ install && bundle _2.5.23_ exec jekyll build"

# Serve at http://localhost:4000 (add -it -p 4000:4000 and `jekyll serve -H 0.0.0.0`)
```

If you have a working local toolchain instead, `bundle install` then
`bundle exec jekyll serve` works the same way.

## Deployment

`.github/workflows/pages.yml` builds the site and deploys it to GitHub Pages on
every push to `main`. In the repository settings, Pages must be set to deploy
from **GitHub Actions**.

## Public content rules

This is a **public** repository. Do not commit private or internal material.
`.gitignore` and `_config.yml` exclude common private folders (`private/`,
`internal/`, `migration-notes/`, `google-sites-export/`), but always review
changes before committing. See `AGENTS.md` for the full content and privacy
rules.
