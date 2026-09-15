# Design brief: wordmark, collaborator map, home page

For the designer working on `design/paper-and-ink`. You have repository access —
read the real files rather than working from description, and build with the real
content in `_data/*.yml`, never with placeholder text.

Three separate jobs, in increasing order of size. Read "The system you are
working inside" first; it constrains all three.

---

## The system you are working inside

The site was restyled as **paper and ink**: one ground colour, no cards,
structure from whitespace and hairline rules. A full-width rule means "section
divider"; a rule that hugs the text column means "item separator". The design
rules are documented in the header comment of `assets/css/main.scss` and in the
Styling section of `DEVELOPING.md`. Read both.

**Tokens** (from `assets/css/main.scss`, use these, do not invent new ones):

| | |
| --- | --- |
| paper `#fdfdfb` | the single ground |
| ink `#17212b` | blue-black, all body text |
| ink-soft `#55616e` | secondary text |
| ink-faint `#8b939c` | markers, non-text only |
| rule `#e2e0d9` / rule-strong `#c5c3bb` | hairlines |
| accent `#1a4a7a` | links and the primary button, nothing decorative |

**Discipline colours** — these are the motion arcs of the three spinning tops in
the emblem, and they are the only colours besides the accent that carry meaning:
Geom `#46698f`, Math `#8263a0`, Phys `#b96528`, Philo `#5f7d4f`.

**Type** — STIX Two Text (titles and prose; it is the text companion of the STIX
fonts used by mathematics and physics journals) and IBM Plex Sans (navigation,
dates, meta lines only). Both self-hosted in `assets/fonts/`. Sentence case
throughout; no uppercase display type, no letter-spaced labels above headings.

**Hard constraints**

- **Jekyll, data-driven.** Every section must be rendered from `_data/*.yml` by a
  Liquid template. Content is not written into layouts. See `DEVELOPING.md`.
- **Do not invent content.** No fictional people, papers, grants or events, and
  no numbers that are not derived from the data at build time.
- **Adding a data field costs three edits** — the `_data` file *and its
  plain-language comment header*, the template that renders it, and the schema in
  `bin/validate_data.rb`. CI blocks the deploy on that schema. Prefer designs
  that use fields which already exist.
- **No third-party asset requests.** Fonts are self-hosted; there are no CDN
  scripts, stylesheets or images. Keep it that way.
- **Accessibility floor**: text at 4.5:1, non-text at 3:1; visible keyboard
  focus; `prefers-reduced-motion` respected; works at 380 px with no sideways
  scroll on any page.
- **SVG conventions**: one `<svg>` root with `viewBox` and **no** `width`/
  `height`; transparent; strokes not filled outline shapes;
  `stroke="currentColor"` for ink so artwork survives on a dark ground; no
  gradients, filters, masks, `<image>`, `<text>` or editor metadata. The nine
  SVGs already in `_includes/icons/` and `assets/images/marks/` are the reference
  for house style — match their pen.

**Lessons already paid for. Do not repeat these.**

- An earlier version put a pendulum phase portrait behind the hero. It was
  removed: it was *geometry about nothing in particular*, so it read as
  wallpaper. Ornament must encode something true or not exist.
- Stock photography was removed for the same reason.
- Numbered markers (01 / 02 / 03), all-caps eyebrow labels above headings, and
  meta strings joined with middle dots were all removed. Don't bring them back.
- Everything used to be a bordered, shadowed card. Border, fill, radius and
  shadow each say "separate object" — spend them by role, not uniformly.

---

## Job 1 — Redraw the wordmark as SVG *(small, well-defined)*

**The problem.** `assets/images/logos/geommphys-horizontal.png` is the last
raster asset on the site, and it now sits in the header next to freshly drawn
vector icons. A 1000×427 bitmap scaled to 196 px, with softly antialiased
lettering, reads as slightly soft and out of place beside hairline vector line
art. It also still needs a `filter: invert()` + `mix-blend-mode: screen`
workaround to survive on a dark ground, which is the last such hack left.

**Deliver** `logo-horizontal.svg` — the three tops plus the hand-lettered group
name, as one lockup.

- The lettering must be **outlined paths**, not `<text>`, so there is no font
  dependency. Match the existing spaced small-caps: letterspacing, cap height and
  the two-line arrangement ("GEOMETRICAL MATHEMATICAL PHYSICS" over "RESEARCH
  GROUP" with its flanking rules).
- Optical weight of the lettering strokes must sit with the tops' stroke weight,
  not lighter or heavier.
- Must read at **196 px wide** (desktop header) and **168 px** (mobile).
- `stroke="currentColor"` for the ink, discipline colours for the arcs.

**Honest warning.** Lettering is exactly where vector redraws of hand-drawn work
start to look amateurish. If you cannot match the lettering convincingly,
**deliver the tops-only lockup instead and say so** — we will keep the raster
wordmark rather than ship worse lettering. A `logo-vertical.svg` is optional.

---

## Job 2 — Redesign the collaborator map *(medium)*

Read `_includes/network-map.html` and `_data/network.yml`.

**What exists.** A hand-plotted world map: a dot-lattice `<pattern>` clipped to
land paths, nine collaborator dots plus Madrid, a "Europe" breakout inset
hanging over the frame's bottom-right corner, and a JS tooltip listing each
location's members (resolved from `people.yml` by id).

**Why it needs redesigning.**

1. It was designed as a modest 780 px element mid-page. It is now presented as a
   signature element at 940 px on both the home and People pages, and it does not
   carry that size — the lattice gets fussy and the composition thin.
2. **The Europe inset is a workaround, not a design.** Six of the nine locations
   are European, so the cluster is too tight to tap; the breakout exists to make
   them reachable. It also floats over the frame's corner, which required a
   caption fix. Solve the underlying problem instead.
3. **The dots encode nothing.** All nine are the same purple, Madrid is orange.
   Every location has members, and every member has a discipline — there is real
   structure available and none of it shows.
4. Only four locations carry a visible label; the rest are discoverable only by
   hover, which fails on touch and in a screenshot.

**The real data.** Nine institutions plus Madrid, on three continents: MIT
(Massachusetts), Kyoto RIMS, NTU Singapore, University of Warsaw, University of
Tartu, Munich School of Philosophy, Inria (France), Ruđer Bošković (Croatia),
UPC (Catalonia). Six are European. Member counts per location range from one to
three.

**Critical technical constraint.** `network.yml` stores each location as `x`/`y`
pixel coordinates tied to the current `viewBox` and projection, and its comment
header warns non-technical editors that *"changing NUMBERS moves things"*. So
either:

- **keep the existing viewBox and projection** and redesign everything else, or
- **deliver a new coordinate table for all ten locations** plus replacement
  comment-header text explaining the new system to a non-technical editor.

Do not silently change the projection.

**Deliver** a redesigned map as SVG plus a short note on the interaction model
(what is visible at rest, what hover and touch add, and how it degrades in a
static screenshot). Consider whether a world map is even the right frame for nine
points, six of which are in Europe — a different arrangement may serve the
content better, and that is a legitimate answer.

---

## Job 3 — Redesign the home page *(the big one)*

Read `_layouts/home.html` and `index.md`.

**The diagnosis, with numbers.** The site holds a substantial body of work:

| | |
| --- | --- |
| **27** publications | 2024–2026: 11 in 2026, 13 in 2025, 3 in 2024 |
| **3** research lines | Multisymplectic Field Theory (6 members), Beyond Integrability (5), Quantum systems and topological phases of matter (3) — each with 4 keywords |
| **22** members | 8 researchers and 4 students in Madrid, 10 international collaborators, plus 7 visitors |
| **4** disciplines | physics 10, geometry 9, mathematics 2, philosophy 1 |
| **17** past seminars | with speakers, affiliations, and abstracts that now typeset LaTeX |
| **10** institutions | across three continents |
| **10** research visits, **11** outreach activities, **4** awards, **4** workshops | |

The home page currently shows: the emblem and name, one sentence of intro, three
cards that are really just links to site sections, an **empty** "Upcoming
seminars" list, and the map. **None of the substance above is visible.** That is
the problem to solve — not the styling, which is fine.

**Three specific faults**

1. `_data/research.yml` is **not** research areas. Its five entries are
   Publications, Group seminars, Research visits, Conferences and workshops,
   Awards and honours — site sections. The home page presents them under
   "Research", which is misleading. The actual research areas are the three
   research lines in `research_lines.yml`, and they have descriptions, keywords
   and member lists that no one currently sees on the home page.
2. `seminars.upcoming` is **empty, and will often be empty** between terms. A
   design that ends the page on "Upcoming seminars will be posted here" is a
   design that will usually look broken. Empty states are a first-class
   requirement here, not an edge case. There is a drawn mark for them
   (`assets/images/marks/mark-empty.svg`).
3. The intro band is one sentence in a wide empty space. Either give it real
   material or remove the band.

**Deliver** a home page design — desktop and 400 px — specifying for each
section: what it says, which `_data` file and fields it reads, how it looks when
that data is empty, and the type and spacing it uses from the system above.

**Worth considering** (suggestions, not requirements): leading with the three
research lines, since they are the actual work and are described in real prose;
showing the most recent publications, since 24 of 27 are from the last two years
and that is evidence of an active group; making the four disciplines visible,
since the split across geometry, mathematics, physics *and philosophy* is
genuinely unusual and currently invisible; and giving the last seminars a place
so the page has substance even when nothing is scheduled.

**Do not** solve this with big-number stat tiles — a row of "27 / 22 / 10"
counters is the default move and it reduces real work to marketing.

---

## How each job will be judged

Built with the project's own toolchain, then checked: the page builds, no
sideways scroll at 380 px on any of the 13 pages, contrast at 4.5:1 for text and
3:1 for non-text, no new third-party requests, and `ruby bin/validate_data.rb`
still passes. Then rendered at real display sizes and looked at beside the
existing pages — artwork next to the existing tops, layouts next to the other
templates.

If something does not hold up, say so and leave it out. Shipping nothing is
better than shipping off-brand.
