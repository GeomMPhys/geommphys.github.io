# Self-hosted web fonts

Both families are licensed under the SIL Open Font License 1.1 and are served
from this repository (no third-party requests, so no visitor data leaves
GitHub Pages).

| Family | Role on the site | Files |
| --- | --- | --- |
| **STIX Two Text** | Titles and prose. The serif of scientific publishing — the text companion to the STIX math fonts used by physics and mathematics journals. | `stix-two-text-*` |
| **IBM Plex Sans** | Apparatus only: navigation, dates, meta lines, link chips. | `ibm-plex-sans-*` |

Each file is a **variable** font (one file covers the whole weight range), in
two subsets: `latin` (U+0000–00FF) and `latin-ext` (U+0100–02BA…), selected per
subset by `unicode-range` in `assets/css/main.scss`. `latin-ext` covers
collaborator names outside Latin-1.

Sources — upstream projects, both OFL 1.1:

- STIX Two Text: https://github.com/stipub/stixfonts
- IBM Plex Sans: https://github.com/IBM/plex

Retrieved as woff2 subsets via the Google Fonts CSS API (`fonts.gstatic.com`).
To refresh, re-download the `latin` and `latin-ext` woff2 for each face and keep
these filenames; nothing else needs to change.
