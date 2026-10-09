---
title: Contributing
description: The team's Git workflow, how to replace images and sounds, write cutscene scripts, and add translations.
---

This guide is for Varmintz KW Studio team members. The source code lives in the team's private repository.

## Git workflow

| Branch | Purpose |
| --- | --- |
| `main` | Stable / release version. Only accepts merges from `dev` |
| `dev` | Integration. All features are merged here via Pull Request |
| `feat/<name>` | One feature per branch, created from `dev` |
| `fix/<name>` | Bug fixes, created from `dev` |

```bash
git checkout dev && git pull
git checkout -b feat/nama-fitur
# do the work, then:
git add -A
git commit -m "feat(scope): deskripsi singkat"
git push -u origin feat/nama-fitur
# Open a Pull Request to dev, at least 1 reviewer, then merge.
```

New release: merge `dev` into `main`, then create a `vX.Y.Z` tag. Builds and uploads run automatically.

## Illustrator: images

- Sprites are in `assets/sprites/`, dialogue portraits in `assets/portraits/`, cutscene illustrations in `assets/story/`.
- Replace a file using **the same name**; the game picks it up automatically. Full size specs and names are in `docs/ASSET_SPEC.md`.
- Sprites face right, have a transparent background, and any text inside an SVG must be converted to *paths*.

## Audio

Files are in `assets/audio/music/` and `assets/audio/sfx/`, in **WAV** format. Replace a file using the same name.

| Name | When it plays |
| --- | --- |
| `music/menu` | Main menu, recap, and relaxed cutscenes |
| `music/nana` | Sad cutscenes (Nana is sick, the hospital) |
| `music/kilat` | Tense cutscenes (Bang Kilat) |
| `music/gameplay` | During delivery days |
| `sfx/step`, `sfx/pickup`, `sfx/hit`, `sfx/package_damage`, `sfx/fail`, `sfx/delivery`, `sfx/star` | Footsteps, package pickup, collision, package damage, package destroyed, arrival, rating star |
| `sfx/meow`, `sfx/slip`, `sfx/splash`, `sfx/horn`, `sfx/click` | Cat, slipping, falling into water, horn, button |
| `sfx/chime_sad`, `sfx/sting_kilat` | Accents when the cutscene music changes mood |

## Story Writer: scripts

Cutscene scripts are in `resources/story/` and can be edited in Godot's Inspector. Each cutscene has three lists in the same order (one element per page):

| Property | Contents |
| --- | --- |
| `pages` | Page text. The tokens `{saved}`, `{target}`, `{left}` are replaced with the savings, the treatment cost, and the shortfall |
| `speakers` | `character:expression` (e.g. `nana:senang`), or empty for narration |
| `images` | An illustration from `assets/story/`. Empty = keep the previous image |

Whenever you change script text, update its key in `translations/strings.csv` too.

## Translations

`translations/strings.csv` can be edited with Excel, Google Sheets, or a text editor. The `keys` column holds the exact Indonesian text, and the `en` column holds the English translation. Text with `%s` / `%d` must keep the same placeholders.

## This wiki

The wiki content is in the `wiki/` folder of the repository, written in Markdown. Indonesian pages are in `wiki/src/content/docs/`, and English versions are in `wiki/src/content/docs/en/` with the same file names. Changes merged into `main` go live automatically.

```bash
cd wiki
npm install
npm run dev     # preview at http://localhost:4321
```
