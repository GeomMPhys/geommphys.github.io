# Developer guide

How the site works under the hood, for people changing templates, styles, the
build, or the data schema. If you only need to **edit content** (add a person,
paper, seminar…), you don't need this file — see `README.md`.

Related docs: `README.md` (content editing, for non-technical users) and
`AGENTS.md` (the rules to follow when making changes).

## Philosophy: data-driven Jekyll

Almost nothing on this site is hand-written HTML. Content lives as structured
YAML in `_data/`, and each page is a thin template that loops over a data file
and delegates rendering to a small include. Adding content means editing YAML;
changing how content *looks* means editing a template or the stylesheet. Keep it
that way — prefer a new include over duplicated markup, and prefer moving a value
into `_data/` over hard-coding it in a page.

## Directory layout

```
_config.yml            Jekyll config (markdown, plugins, permalinks, excludes)
_data/*.yml            The source of truth for all content
_layouts/              Page shells: default.html → home.html / page.html
_includes/             Reusable renderers (one per content type) + helpers
assets/css/main.scss   All styling (compiled to /assets/css/main.css)
assets/images/         Photos, profile icons, etc.
*.md (repo root)       The pages; front matter + a few lines of Liquid each
bin/validate_data.rb   Schema validator for _data/*.yml (run in CI)
.github/workflows/     pages.yml (build+deploy) and validate.yml (data checks)
```

## The rendering pipeline

A request for `/publications/` resolves like this:

1. **`_config.yml`** sets `permalink: pretty`, loads the plugins
   (`jekyll-feed`, `jekyll-seo-tag`, `jekyll-sitemap`), and applies a default
   `layout: page` to every page via `defaults:`.
2. **The page** `publications.md` has front matter (`title`, `permalink`, …) and
   a few lines of Liquid. It pulls its data and hands off to an include:
   ```liquid
   {% assign publications = site.data.publications.selected %}
   {% include publication-list.html publications=publications %}
   ```
   `site.data.publications` is Jekyll auto-loading `_data/publications.yml` — the
   filename (minus `.yml`) becomes the key.
3. **The list include** `_includes/publication-list.html` groups by year and, per
   item, calls the item renderer `{% include publication.html publication=... %}`.
4. **The item include** `_includes/publication.html` emits the actual `<article>`
   markup for one paper — **this is the only place that reads the field names**
   (`publication.title`, `.arxiv`, `.doi`, …). A field that isn't referenced here
   renders nothing, no matter what's in the YAML.
5. **The layout** `_layouts/page.html` → `_layouts/default.html` wraps the result
   in `<html>`, the header/footer includes, `{% seo %}`, and the stylesheet.

Every list page follows this **page → list include → item include** shape.
`people.md` is a slight variant: it iterates the groups in `_data/people.yml`
(`researchers_madrid`, `students_madrid`, `international_collaborators`) and calls
`person-card.html` per person.

## The people-id linking model

Every person in `_data/people.yml` has a stable `id` slug (lowercase, hyphenated).
Other data files reference a person **by that id**, never by retyping the name;
templates resolve the id back to a name (and often a link to their People-page
card via the `#id` anchor set in `person-card.html`).

The resolution helper is `_includes/person-name.html`:
```liquid
{% include person-name.html id=some_id people=site.data.people.<group> link=true %}
```
It does `people | where: "id", id | first` and prints the name, or falls back to
the raw id if not found. `research-visit.html` does the same lookup inline. This
is exactly the cross-reference the validator enforces: a `person`/`people`/
organizer id that isn't in `people.yml` is a broken link, so CI rejects it.

A reference can also be an inline `{ name, affiliation }` mapping — used for
external people not in `people.yml` (e.g. outside workshop co-organizers).
`research_visits.yml` is the exception: id-only.

## Includes reference

| Include | Renders | Read from |
|---|---|---|
| `person-card.html` | a person tile (photo, role, profile icons) | `people.md` |
| `person-name.html` | id → name (optionally linked) | anywhere resolving ids |
| `publication-list.html` / `publication.html` | papers, grouped by year | `publications.md` |
| `seminar-item.html` | one seminar | `seminars.md` |
| `research-line.html` | one research line | `research-lines.md` |
| `research-visit.html` | one visit (uses `date-range.html`) | `research-visits.md` |
| `workshop.html` | one conference/workshop/school | `conferences-workshops.md` |
| `outreach-item.html` | one outreach activity | `outreach.md` |
| `research-area.html` | a card on the Research overview | `research.md` |
| `calendar.html` | the FullCalendar event view + subscribe links | `calendar.md` |
| `network-map.html` | the SVG collaborator map (member ids → hover tooltip) | `people.md` |
| `date-range.html` | human date ranges incl. cross-year | visits, workshops |
| `header.html` / `footer.html` | nav (from `navigation.yml`) and footer | layout |

## Data validation and schema changes

`bin/validate_data.rb` is the machine-checked schema for `_data/*.yml`. It uses
only the Ruby standard library (no `bundle install`) and checks: YAML parses,
required fields are present and non-blank, field-name typos, value types
(`year`, dates), allowed values (enums), and that every person cross-reference
resolves. Run it after any data edit:

```bash
ruby bin/validate_data.rb
```

CI enforces the same check: `.github/workflows/validate.yml` runs it on pull
requests and branch pushes, and `pages.yml` runs it before the build so a bad
push to `main` fails instead of deploying broken data.

**Changing the format** of a data file (add/rename a field, add an allowed value,
add a new data file) means keeping three things in sync, or the change either
fails CI or silently does nothing:

1. **The data file and its comment header** — the header is the human-readable
   spec each editor reads first.
2. **The template that renders it** (`_includes/*.html` or the page's `.md`) — a
   new field displays nothing until it is referenced here.
3. **The schema in `bin/validate_data.rb`** — add the field to the `required:`
   or `optional:` map for that file, extend an enum array (e.g. `OUTREACH_KIND`),
   or add a whole new per-file validation block. A new **required** field must
   also be backfilled on every existing entry, or validation fails.

### Adding a whole new content type (end to end)

1. Create `_data/<thing>.yml` with a comment header and the entries.
2. Add a validation block for it in `bin/validate_data.rb`.
3. Create `_includes/<thing>-item.html` (and a list include if it groups).
4. Create `<thing>.md` with front matter + the page → include wiring.
5. Add it to `_data/navigation.yml` so it appears in the menu.
6. Run `ruby bin/validate_data.rb`, then build and preview.

## Calendar and the .ics feed

The `/calendar/` page (`calendar.md` → `_includes/calendar.html`) shows a
[FullCalendar](https://fullcalendar.io/) month/agenda view built from four data
files — `seminars.yml`, `workshops.yml`, `research_visits.yml`, and dated entries
in `outreach.yml` — coloured by category. The library is **vendored** at
`assets/js/fullcalendar.min.js` (v6 standard global build; it injects its own
CSS) so the site stays self-contained; calendar-specific styling is in the
"Calendar page" section of `main.scss`. Events are generated inline as a JS array
by Liquid at build time — no plugin, no fetch. Visit `person` ids are resolved to
names against `people.yml`. Outreach uses a single flexible `date` (a full
`YYYY-MM-DD`, a `YYYY-MM`, or just a year); entries that are not a full date are
omitted from the calendar since they can't be placed on a day.

`events.ics` (root, `permalink: /events.ics`, `layout: null`) generates the same
events as a subscribable iCal feed from the same data. The calendar page links to
it for download and for Google/Apple/Outlook subscription. Multi-day events use
an exclusive end date (`end + 1 day`), per both FullCalendar and iCal `VALUE=DATE`
conventions. Adding an event to any of the four data files updates both the
on-page calendar and the feed automatically — nothing calendar-specific to edit.

## Private site and internal content

Not everything is public. Two sibling repositories hold members-only material:

- **`GeomMPhys/geommphys.github.io-private`** — members-only *pages* (a members
  hub, news, meetings calendar, grants deadlines, and a certificate generator).
  They are **overlaid onto this site's theme**, built, **StatiCrypt-encrypted**
  with a shared members password, and the encrypted HTML is pushed back into
  *this* repo under `/members/`, `/news/`, `/meetings/`, `/grants/`,
  `/certificates/`. If you see an encrypted blob at those paths, that's why —
  **don't hand-edit them; they're generated.** The public footer's "Members"
  link points at `/members/`, and those private pages share a small top bar via
  `_includes/members-nav.html` (external links there are marked with ↗).
- **`GeomMPhys/group-documents`** — the confidential vault (grant proposals,
  outreach materials, admin docs, logos, templates), gated by real GitHub
  per-member access. The private pages *link* to it; nothing confidential is
  embedded in the site.

**Security boundary:** StatiCrypt's encrypted output is publicly downloadable, so
the private *pages* are for low-sensitivity, members-only content and links only;
anything genuinely confidential lives in `group-documents`. Never commit private
or confidential material into this public repo.

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
`bundle exec jekyll serve` works the same way. Keep the generated `_site/` out of
version control.

## Deployment

`.github/workflows/pages.yml` validates the data, builds the site, and deploys it
to GitHub Pages on every push to `main`. In the repository settings, Pages must
be set to deploy from **GitHub Actions**.

## Styling

All CSS lives in `assets/css/main.scss` (compiled to `main.css`; `sass.style:
compressed` in `_config.yml`). Keep the design restrained, academic, responsive,
and accessible, and reuse the existing class system (`.card`, `.publication`,
`.record`, `.stack`, `.meta`, `.links`, …) rather than adding one-off styles.
