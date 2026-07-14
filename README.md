# Geometry and Mathematical Physics Website

Public Jekyll website for the Geometry and Mathematical Physics group, deployed
to GitHub Pages. Content is **data-driven**: most pages are thin templates that
render structured data from `_data/`, so routine updates mean editing YAML, not
HTML.

## How the site is organised

- **Pages** (repository root, Markdown): `index.md`, `people.md`, `research.md`,
  `research-lines.md`, `publications.md`, `research-visits.md`, `seminars.md`,
  `conferences-workshops.md`, `awards-honours.md`, `outreach.md`, `diversity.md`.
  Most of these just loop over a data file and call an include. (`contact.md` and
  `_data/contact.yml` are retained for possible future use, but the Contact page
  is not published or in the navigation.)
- **Data** (`_data/`): the source of truth for content.
  - `site.yml`, `navigation.yml`, `contact.yml` — site metadata, menu, contact.
  - `people.yml` — everyone, grouped and given a stable `id` (see below).
  - `network.yml` — drives the SVG international network map on the People page.
  - `publications.yml`, `seminars.yml`, `research.yml` — existing content.
  - `research_lines.yml`, `research_visits.yml`, `awards.yml`, `workshops.yml`,
    `outreach.yml` — structured content for the corresponding pages.
- **Templates** (`_layouts/`, `_includes/`): shared structure. Item renderers
  live in `_includes/` (`person-card.html`, `publication.html`, `seminar-item.html`,
  `research-line.html`, `research-visit.html`, `workshop.html`, `outreach-item.html`,
  `research-area.html`, `calendar.html`, `network-map.html`, `ics-events.html`,
  plus the helpers `person-name.html` and `date-range.html`). See `DEVELOPING.md`
  for the full includes reference.
- **Styles**: `assets/css/main.scss`.

## People and the linking convention

Every person in `_data/people.yml` has a stable `id` slug. Other data files
reference people **by that id**, and the templates resolve it to the person's
name (and, on some pages, a link to their card on the People page).

```yaml
researchers_madrid:
  - id: ada-lovelace          # stable slug — referenced from other files
    name: "Ada Lovelace"
    photo: "/assets/images/people-icons/math_icon.png"
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
every visitor must exist in `people.yml` (typically under `visitors`). Each visit
carries its own `affiliation` (the institution the person visited from); for
group members/collaborators it overrides their `people.yml` `role`.

## Editing content

**Every file in `_data/` starts with a comment header** explaining, in plain
language, what page it controls, the YAML rules to respect (spaces not tabs,
quoting), how to add an entry, and what each field means. The quickest way to
edit content is to open the relevant file and read that header — the summaries
below mirror it.

### Add a person

Add an entry under the right group in `_data/people.yml`, giving it a unique
`id` (lowercase, hyphenated). `role` is a free-text position descriptor (it may
be left blank). Photos referenced with `photo:`.

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
    affiliation: "Institution, Country"   # institution visited from
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
    date: 2026-05-20               # required; full date, or 2026-05, or just 2026
    lang: es                       # optional
    links:                         # optional
      - { label: "Watch", url: "https://..." }
```

### Publications and seminars

`_data/publications.yml` (`selected:`) groups by `year`; `_data/seminars.yml`
has `upcoming:` and `past:` lists. See existing entries for the shape.

### Update the international network map

The People page includes a lightweight SVG network map driven by
`_data/network.yml`. Use only public affiliation information. Each location's
`label`, `subtitle`, and `members` show in a tooltip when you hover or tap its
dot; `members` is a list of **person ids from people.yml** (names are resolved
automatically), so a person renamed there updates the map too. European
locations sit too close together to tap, so those marked `inset: true` also
appear, spread out, in a zoomed **Europe inset** in the corner. The `x` and `y`
numbers position the point — adjust them only when adding or moving a location,
and always preview the result.

## For developers

Changing templates, styles, the build, or the data schema — rather than editing
content — is covered separately in **`DEVELOPING.md`**: how the data-driven
rendering works, the includes, local build/preview with Docker, deployment, and
the data validator. Rules to follow when making changes are in `AGENTS.md`.

## Internal documents

Internal group documents must **not** be committed to this public repository. Use
the separate private repository `GeomMPhys/group-documents` for certificate
templates, logo source files, and administrative documents. Suggested layout:

```text
certificate-templates/
logos/
administrative-documents/
other-documents/
```

The website footer links to the members area (`/members/`), whose navigation
links out to this private repository; only users granted access can view or
upload there.

## Public content rules

This is a **public** repository. Do not commit private or internal material.
`.gitignore` and `_config.yml` exclude common private folders (`private/`,
`internal/`, `migration-notes/`, `google-sites-export/`), but always review
changes before committing. See `AGENTS.md` for the full content and privacy
rules.
