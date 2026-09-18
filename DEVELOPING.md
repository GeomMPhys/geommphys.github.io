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
`people.md` is a slight variant: it iterates the displayed groups in
`_data/people.yml` (`researchers_madrid`, `students_madrid`,
`international_collaborators`) and calls `person-card.html` per person. A fourth
group, `visitors`, is *not* shown on the People page but is resolved by other
pages (research visits, calendar, network map) for names.

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
external people not in `people.yml`. Two files mix the two forms in one list:
`workshops.yml` (`organizers`) and `publications.yml` (`authors`), where a group
member is their id and an outside co-author is `{ name: "..." }`.
`research_visits.yml` is the exception: id-only.

One consequence of linking authors by id: a member's name is printed from
`people.yml`, so a paper cannot show its own spelling of it. The data used to
carry both `"M. Lainz Valcázar"` and `"M. Lainz"`; it now shows the canonical
name everywhere. That was the deliberate trade for the links.

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
| `calendar.html` | the FullCalendar event view + per-category subscribe links | `calendar.md` |
| `ics-events.html` | iCal VEVENTs for a category (`only=`), used by the `.ics` feeds | `events*.ics` |
| `network-map.html` | the SVG collaborator map (member ids → hover tooltip) | `people.md` |
| `date-range.html` | human date ranges incl. cross-year | visits, workshops |
| `theme-init.html` | pre-paint theme + `data-js` on `<html>` | `_layouts/default.html`, in `<head>` |
| `theme-switch.html` | the Auto / Day / Night control | `header.html` |
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

Subscribable **iCal feeds** are generated from the same data, so visitors can
subscribe to only the categories they want:

- `/events.ics` — all events
- `/events-seminars.ics`, `/events-workshops.ics`, `/events-visits.ics`,
  `/events-outreach.ics` — one category each

Each `.ics` file (root, `permalink`, `layout: null`) is a thin VCALENDAR wrapper
that calls `_includes/ics-events.html` with an `only=` parameter; that include
holds the single copy of the VEVENT-generation logic. The calendar page's
"Subscribe" row links to each feed (webcal) plus download-all. Multi-day events
use an exclusive end date (`end + 1 day`), per both FullCalendar and iCal
`VALUE=DATE`. Adding an event to any data file updates the on-page calendar and
all relevant feeds automatically. (Note: feed `UID`s are derived from each
event's date + a title slug, so reordering entries doesn't churn subscribers'
calendars.)

## Private site and internal content

Not everything is public. Two sibling repositories hold members-only material:

- **`GeomMPhys/geommphys.github.io-private`** — members-only *pages* (a members
  hub, news, meetings calendar, grants deadlines, and a certificate generator).
  They are **overlaid onto this site's theme**, built, **StatiCrypt-encrypted**
  with a shared members password, and the encrypted HTML is pushed back into
  *this* repo under `/members/`, `/news/`, `/meetings/`, `/grants/`,
  `/certificates/`. If you see an encrypted blob at those paths, that's why —
  **don't hand-edit them; they're generated.** The public footer's "Members"
  link points at `/members/`. On those pages (`section: Private`) the header
  swaps the public nav for a members nav (see `_includes/header.html`): its
  Members / News / Calendar / Deadlines / Certificates items are the generated
  private pages, while Grants / Outreach / Documents are **external links to the
  vault** (marked with ↗).
- **`GeomMPhys/group-documents`** — the confidential vault (grant proposals,
  outreach materials, admin docs, logos, templates), gated by real GitHub
  per-member access. The private pages *link* to it; nothing confidential is
  embedded in the site.

**Security boundary:** StatiCrypt's encrypted output is publicly downloadable, so
the private *pages* are for low-sensitivity, members-only content and links only;
anything genuinely confidential lives in `group-documents`. Never commit private
or confidential material into this public repo.

**Auto-refresh when public data changes:** the private certificate generator
embeds *public* data from this repo (`_data/seminars.yml`, `research_visits.yml`,
`people.yml`), so its encrypted page can go stale when that data changes here.
`.github/workflows/notify-private.yml` handles it: on any push to `main` touching
`_data/**`, it fires a `repository_dispatch` (`public-data-changed`) at the private
repo, which rebuilds and republishes the encrypted pages. It needs a
`PRIVATE_REPO_DISPATCH_TOKEN` secret in *this* repo (a token allowed to dispatch to
`geommphys.github.io-private`). Loop-safe: it fires only on `_data/**`, and the
private repo's bot pushes back only `*/index.html`, so those commits can't
retrigger it.

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
The stylesheet opens with a comment block stating the design rules; read it
before changing anything visual. In short:

- **Paper and ink.** One background colour and no cards. Structure comes from
  whitespace and hairline rules, not from boxes. A full-width rule means
  "section divider"; a rule that hugs the text column means "item separator".
- **Two typefaces, self-hosted.** *STIX Two Text* (the text companion to the
  STIX fonts used by mathematics and physics journals) for titles and prose;
  *IBM Plex Sans* for apparatus only — navigation, dates, meta lines, link
  rows. Files and licensing: `assets/fonts/README.md`. No third-party font
  requests, so no visitor data leaves GitHub Pages.
- **One accent** (`--accent`, ink blue) for links and the primary button. The
  blue/purple/orange of the logo's spinning tops are *not* decoration: they
  appear only in the calendar legend and the collaborator map, where they
  identify event categories. Those hexes are literals in
  `_includes/calendar.html` and `_includes/network-map.html` (FullCalendar
  needs them inside its JS), so change them there, not in the stylesheet.
- **Sentence case throughout.** No uppercase display type, no letter-spaced
  labels above headings, no monospace outside `<code>`, no decorative shadows.
  `.eyebrow` is retained only as a graceful fallback for the encrypted members
  pages built against the previous theme; do not add new ones.
- Photographs are used at their own size (see `.page-figure` on the Research
  page), never as a scrim behind heading text.

Contrast was checked against WCAG AA: body 16:1, secondary text 6.2:1, links
9:1 on the paper background. Keep new colours at 4.5:1 or better for text.

### Day and night

The stylesheet ships two palettes. The light one is the bare `:root` block; the
night one is the `@mixin night` at the very bottom of `main.scss` — **the only
Sass construct in the file**, and there for a reason: the palette is used twice
(once for readers following their operating system, once for a reader who chose
Night outright) and two hand-kept copies would drift apart the first time
someone tuned one of them. Add a token to the mixin, not to one of its two call
sites. Both blocks must stay at the end of the file: several of the overrides
are plain class selectors at the same specificity as the rules they beat, so
they win on order.

Night moves tokens and nothing else — no layout changes, no second set of
artwork, no `filter: invert()`. Marks follow because they are inlined SVG whose
ink is `currentColor`.

The reader's choice is three-state, because "follow my desktop" is the site's
default and a two-way toggle would give no way back to it:

| `<html>` | means |
|---|---|
| no `data-theme` | follow `prefers-color-scheme` — the default, and what a reader with no stored choice gets |
| `data-theme="light"` | Day, overriding a dark desktop (the `:not([data-theme="light"])` in the media query is what lets it) |
| `data-theme="dark"` | Night, overriding a light desktop |

Two includes implement it. `theme-init.html` runs in `<head>`, before the page
paints — a deferred script would flash white at every navigation for a reader
who chose Night. It also sets `data-js` on `<html>`, which is the only thing
that reveals the control: without scripting it would be a row of buttons that
do nothing, so the stylesheet hides it. `theme-switch.html` carries the markup
and an inline (not deferred) script, so the pressed button is marked the moment
the buttons are parsed.

The choice is kept in `localStorage` under `theme`. Every read and write is
wrapped, because a locked-down browser throws rather than returning `null`;
failing it falls back to the desktop setting, which is a working site.

`color-scheme` is declared in both palettes so the browser's own furniture —
scrollbars, form controls, the caret — matches. It has to be stated explicitly
now that a reader can pick Night on a light desktop.

### Mathematics in abstracts

Seminar abstracts may contain LaTeX between dollar signs (`$G_2$`), and it is
typeset as real mathematics. The mechanism is deliberately minimal:

- `assets/vendor/katex/` holds **only** `katex.min.js` and
  `auto-render.min.js` (KaTeX 0.16.11). KaTeX is used purely as the *parser*:
  `_includes/math.html` calls `renderMathInElement` with `output: "mathml"`, so
  it emits MathML and the **browser** does the layout. That is why there is no
  `katex.min.css` and no KaTeX font files — those exist only for its HTML output
  mode, and would add 23 KB of CSS plus ~20 woff2 faces. The mathematics is
  therefore real text: selectable, copyable, and read correctly by screen
  readers, with the original LaTeX preserved in a MathML `<annotation>`.
- Rendering is **scoped to `.record__note` and `.record__meta`**. Never widen it
  to `document.body`: a whole-page pass would treat any stray `$` in a title,
  venue or person's name as the start of a formula.
- Pages opt in with `math: true` in their front matter (`seminars.md`,
  `index.md`); `_layouts/default.html` includes the script only for those.
- MathML needs a font with an OpenType MATH table. The `math` rule in
  `main.scss` names the ones this audience actually has — STIX Two Math (the
  metric companion of the site's STIX Two Text, and shipped with macOS), Cambria
  Math (Windows), Latin Modern Math (every TeX installation), and several common
  on Linux. Self-hosting STIX Two Math was measured at **393 KB**, more than
  every text face on the site combined, so it is not shipped; revisit only if
  display-heavy mathematics arrives. Without a math font, subscripts get wide
  side bearings and `G_2-structures` visibly gapes — that is the symptom.
- With JavaScript disabled the raw `$…$` shows, exactly as before.

### Illustration

The group's artwork is hand-drawn: spinning tops labelled Geom, Math, Phys and
Philo, used as the emblem and as per-person discipline icons. New artwork should
match that hand. Requirements differ by route:

**Drawn as SVG** — one `<svg>` root with `xmlns` and `viewBox` and **no
`width`/`height`** so CSS controls the size; transparent, with no background
rect; strokes rather than filled outline shapes, `stroke-linecap`/`linejoin`
round; **`stroke="currentColor"` for all ink**, which is what carries the
artwork into night mode without a second copy; discipline colours as literals — Geom
`#46698f`, Math `#8263a0`, Phys `#b96528`, Philo `#5f7d4f`; no gradients,
filters, masks, clip paths, `<image>` or `<text>`; no editor metadata.

**Drawn on paper and scanned** — deliver a transparent PNG at 2× the display
size. **If you scan it, leave the background pure white and untouched.** The
existing artwork could only be cut out because the exterior was exactly
`255,255,255` while the drawings' own interior shading sat at 248-251, which let
a zero-fuzz flood fill from the corners separate them. A grey, cream or textured
scan background cannot be separated cleanly.

Either way: keep the ink weight consistent with the tops, and bake in no drop
shadows or white halos.

Slots the site has room for: an empty-state mark (~120 px), a footer mark
(~80 px), a 404 figure (~320 px), one mark per research line (~400 px), and an
Open Graph card (1200×630 raster — `jekyll-seo-tag` currently has no `image`, so
shared links preview blank).
