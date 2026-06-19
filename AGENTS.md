# Project Rules for Agents

This repository contains the public Jekyll website for the Geometry and Mathematical Physics group.

## Site Architecture

- Keep the site as a Jekyll project suitable for GitHub Pages.
- Prefer Markdown and YAML data files for content updates.
- Use layouts and includes for repeated structure.
- Avoid hand-written standalone HTML pages unless there is a clear Jekyll reason.
- Keep the design restrained, academic, responsive, and accessible.

## Content

- Do not invent real people, publications, affiliations, grants, or events.
- Use placeholders only when they are clearly temporary and not presented as factual records.
- Keep public content concise and professional.
- Put reusable structured data in `_data/`.
- Put news posts in `_news/`.

## Privacy

- Do not commit private Google Sites exports, internal notes, credentials, unpublished documents, or personal data that is not intended for the public website.
- Keep private material in ignored folders such as `private/`, `internal/`, `migration-notes/`, or `google-sites-export/`.
- Do not expose `.agents/`, `.codex/`, local environment files, or generated build output.

## Development

- Use `bundle exec jekyll serve` for local previews when dependencies are installed.
- Keep generated `_site/` output out of version control.
- Scope design changes to the existing style system in `assets/css/main.scss`.
- Check that navigation, data-driven pages, and GitHub Pages deployment still work after structural edits.
