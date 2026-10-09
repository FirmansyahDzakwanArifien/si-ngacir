---
title: Technology
description: The engine, code architecture, procedural maps, audio system, translations, and automated build pipeline of Si Ngacir.
---

## Engine

- **Godot Engine 4.3 Stable** with GDScript.
- The **Compatibility** renderer (OpenGL ES 3 / WebGL 2) so it runs in browsers and on mid-range phones.
- Vector graphics (SVG) that render crisply at every screen size.

## Code layout

```text
scenes/main.tscn          Title screen
scenes/cutscene.tscn      Cutscene player
scenes/album.tscn         Story Album
scenes/ending.tscn        Recap and ending
scenes/game/level.tscn    A single delivery day

scripts/autoload/         GameState, AudioManager, Accessibility, Transition, Screen
scripts/game/             Level, Player (Masbro), Vehicle, MapGenerator, effects
scripts/game3d/           3D View layer (beta)
scripts/data/             PackageData, LaneData, DayData, StoryData, cosmetics
scripts/ui/               HUD, panels, settings

resources/days/           Day 1–5 data: package, customer, ETA, pay, map parameters
resources/packages/       Durability, fragility, and step speed for each package
resources/story/          Cutscene scripts
resources/cities/         Location theme for each day
translations/strings.csv  Indonesian–English translations
```

Game data (days, packages, story) is stored as *Resources* that can be edited in Godot's Inspector, so the design and writing team can change content without touching code.

## Procedural maps

Each day has its own map parameters. The map is reassembled every time a day starts:

1. The **warehouse** at the bottom, the **customer's house** at the top.
2. In between, a number of **road blocks** (several two-way lanes) or **river blocks** (raft lanes), separated by **safe medians**.
3. Every few blocks, one median becomes a **checkpoint** (Pos).
4. Medians are filled with cones, barriers, and carts; the asphalt sometimes has potholes; coins and power-ups are scattered around.
5. The **pickup stall** is placed on a safe tile at roughly 35–65% of the route length, not in line with the starting point.

Key rule: gaps between vehicles are at least 3 tiles and rafts are always close enough together, so every map is **guaranteed to be completable**. Vehicle speed increases gradually toward the customer's house.

## Audio

Music and sound effects are looked up by file name, so the audio team only has to replace files without changing code. **WAV** files are compressed to QOA on import, because the slim web build doesn't include OGG/MP3 decoders.

## Language

Text is written in Indonesian; English translations live in `translations/strings.csv`. Adding another language just means adding a new column.

## Automated build & release

```text
feat/<name> ──PR──▶ dev ──PR──▶ main ──tag v*──▶ GitHub Actions
                                                    │
                     ┌──────────────┬───────────────┼──────────────┐
                     ▼              ▼               ▼              ▼
                Web (HTML5)     Windows         Android      Build check
                     └──────────────┴───────┬───────┘
                                            ▼
                            GitHub Release + itch.io
```

- Every Pull Request is tested: the project is imported and re-exported.
- Before merging, the team runs the Godot **automated test** suite (23 scenarios: movement, collisions, pickup and delivery, rivers, checkpoints, cutscenes, album, effects, 3D View, and more).
- After export, CI opens the resulting build and fails if any cutscene is empty, a portrait is missing, or music wasn't included.
- The web build uses a **slim Godot template**: unused modules are stripped to keep the download small (±8 MB compressed), but the 3D core stays in for 3D View.
- Pushing a `v*` tag automatically creates a **GitHub Release** and uploads to **itch.io** (web, Windows, and Android channels).
