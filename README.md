# Geometry and Mathematical Physics Website

This is a maintainable Jekyll website for the Geometry and Mathematical Physics group. It is designed for GitHub Pages and keeps most public content in Markdown files or YAML data files.

## Editing Content

- Main pages are Markdown files in the repository root: `index.md`, `people.md`, `research.md`, `publications.md`, `research-visits.md`, `seminars.md`, `conferences-workshops.md`, `awards-honours.md`, `outreach.md`, `diversity.md`, and `contact.md`.
- Group metadata, contact information, and navigation live in `_data/site.yml` and `_data/navigation.yml`.
- People are edited in `_data/people.yml`.
- Research areas are edited in `_data/research.yml`.
- Selected publications are edited in `_data/publications.yml`.
- Seminars are edited in `_data/seminars.yml`.
- Shared page structure lives in `_layouts/` and `_includes/`. Most routine updates should not require editing these files.
- Styles live in `assets/css/main.scss`.

`contact.md` and `_data/contact.yml` are currently retained for possible future use, but the Contact page is not published or included in the navigation.

## Adding a Person

Edit `_data/people.yml` and add an entry under the correct group:

```yaml
faculty:
  - name: "Name Surname"
    role: "Professor"
    email: "name@example.edu"
    website: "https://example.edu/name"
    photo: "/assets/images/people/name-surname.jpg"
    research: "String theory, quantum field theory, and geometry."
    profiles:
      - type: "orcid"
        label: "ORCID"
        url: "https://orcid.org/0000-0000-0000-0000"
      - type: "scholar"
        label: "Google Scholar"
        url: "https://scholar.google.com/citations?user=example"
      - type: "inspire"
        label: "INSPIRE-HEP"
        url: "https://inspirehep.net/authors/example"
```

Photos should be public images placed under `assets/images/people/`. Use lowercase filenames with hyphens.
The optional `profiles` list controls the small profile icons shown on the People page. Use `type: "orcid"`, `type: "scholar"`, or `type: "inspire"` for the existing icon styles.

## Updating the International Network Map

The People page includes a lightweight SVG network map driven by `_data/network.yml`.

Each entry should use only public affiliation information. The `label`, `subtitle`, and `members` fields are displayed on the page. The `x`, `y`, and `curve` fields position the point and connection line in the minimalist SVG map; adjust them only when adding or moving a location.

## Adding a Seminar

Edit `_data/seminars.yml`:

```yaml
upcoming:
  - title: "Seminar title"
    speaker: "Speaker name"
    affiliation: "Speaker affiliation"
    date: 2026-10-01
    time: "14:00"
    location: "Room name"
    abstract: "Short abstract."
```

Move older talks from `upcoming` to `past` when appropriate.

## Adding a Publication

Edit `_data/publications.yml`:

```yaml
selected:
  - title: "Article title"
    authors: "A. Author, B. Author"
    venue: "Journal or preprint information"
    year: 2026
    arxiv: "2601.00000"
    doi: "10.0000/example"
    url: "https://arxiv.org/abs/2601.00000"
```

The Publications page automatically groups entries by year and displays their arXiv or DOI links.

## Updating Outreach and Diversity

Edit `outreach.md` to add public engagement activities under the appropriate year. Edit `diversity.md` to update the group's public equity initiatives and resources. Keep both pages limited to information intended for public release.

## Internal Documents

Internal group documents should not be committed to this public website repository. Use the separate private GitHub repository `GeomMPhys/group-documents` for files such as certificate templates, logo source files, and administrative documents.

Suggested folder structure for the private repository:

```text
certificate-templates/
logos/
administrative-documents/
other-documents/
```

The public website footer links to the private repository. Only GitHub users who have been granted access to that private repository will be able to view, download, or upload documents there.

## Local Preview

Install Ruby and Bundler, then run:

```bash
bundle install
bundle exec jekyll build
bundle exec jekyll serve
```

Open the local URL shown in the terminal, usually `http://127.0.0.1:4000`.

The data files now contain migrated public content. Entries marked `TODO` indicate information that was not present on the public Google Sites page.

## GitHub Pages

The workflow in `.github/workflows/pages.yml` builds and deploys the site when changes are pushed to `main`.

In the GitHub repository settings, set Pages to deploy from GitHub Actions:

1. Open repository settings.
2. Go to Pages.
3. Set the source to GitHub Actions.

## Public Content Rules

Do not commit private or internal migration material to this repository. The `.gitignore` and `_config.yml` exclude common private folders such as `private/`, `internal/`, `migration-notes/`, and `google-sites-export/`, but contributors should still check changes before committing.
