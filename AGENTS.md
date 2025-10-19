<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Repository Guidelines

> 原則として、このリポジトリに関する回答やドキュメント更新時の説明は日本語で行ってください。

## Project Structure & Module Organization
- `docs/ai-prep-manual/` holds the source Markdown, split per chapter (`NN-slug.md`). Edit these files to change content; avoid touching `site/` directly.
- `templates/` provides HTML skeletons (`manual_template.html`, `index_template.html`) shared across manuals.
- `assets/manual.css` defines the visual system and is copied verbatim into the generated site.
- `tools/build_manual.py` is the only build script; treat it as the entry point for any automation.
- `site/` is the generated output. Regenerate instead of hand-editing, and re-run the builder after every docs change.

## Build, Test, and Development Commands
- `python3 tools/build_manual.py` — converts every manual in `docs/` (files or folders) into styled HTML under `site/` and refreshes `site/index.html`.
- `python3 tools/build_manual.py --docs docs --out site-dev` — optional target override for previewing changes without touching the tracked `site/` directory.
- Open `site/index.html` (or custom output path) in a browser to review the result.

## Coding Style & Naming Conventions
- Markdown chapters use leading two-digit prefixes to preserve order (e.g., `07-5-mcpmodel-context-protocol.md`). Keep headings intact so anchors remain stable.
- Python code follows 4-space indentation, type hints, and descriptive helper names; mimic existing patterns inside `tools/`.
- Keep assets in ASCII; embed external images via Markdown links rather than local binaries.

## Testing Guidelines
- No automated test suite yet. After doc or template edits, run the build command and manually spot-check critical sections (TOC links, code fences, image embeds).
- When altering the converter, add temporary Markdown fixtures in `docs/` to exercise the new behavior and inspect the generated HTML before removing them.

## Commit & Pull Request Guidelines
- Use imperative, scope-aware commit messages (e.g., `refactor: tighten TOC link formatting`). Group doc and build changes in separate commits when feasible.
- Pull requests should summarize the affected manuals, note build command output, and include screenshots if the rendered HTML layout changes.
- Link issue IDs or task references in PR bodies, and call out any follow-up work (e.g., missing chapters or CSS refinements).
