# Geometry and Mathematical Physics Website

This is a maintainable Jekyll website for the Geometry and Mathematical Physics group. It is designed for GitHub Pages and keeps most public content in Markdown files or YAML data files.

## Editing Content

- Main pages are Markdown files in the repository root: `index.md`, `people.md`, `research.md`, `publications.md`, `seminars.md`, `news.md`, and `contact.md`.
- Group metadata, contact information, and navigation live in `_data/site.yml` and `_data/navigation.yml`.
- People are edited in `_data/people.yml`.
- Research areas are edited in `_data/research.yml`.
- Selected publications and bibliography profile links are edited in `_data/publications.yml`.
- Seminars are edited in `_data/seminars.yml`.
- News posts are Markdown files in `_news/`.
- Shared page structure lives in `_layouts/` and `_includes/`. Most routine updates should not require editing these files.
- Styles live in `assets/css/main.scss`.

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
```

Photos should be public images placed under `assets/images/people/`. Use lowercase filenames with hyphens.

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

## Adding a News Post

Create a file in `_news/` named with a date prefix:

```text
_news/2026-10-01-new-grant.md
```

Use this format:

```markdown
---
title: New Grant Awarded
date: 2026-10-01
---

Short public announcement text.
```

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

Use selected publications on the website and link to durable public bibliography profiles for full lists.

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
