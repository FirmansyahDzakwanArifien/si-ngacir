---
title: 3D View
description: How 3D View (beta) is built on top of the same 2D logic, test scenarios, and the next development stages.
---

3D View has been a **beta** option since v0.11 (Windows, Android) and v0.12 (browser). The 2D version remains the main view.

## Principle: one logic, two views

The game logic (grid, collisions, ETA, pickup and delivery, effects) stays single. 3D View is just a **presentation layer** that reads the level's state every frame.

```text
MapGenerator ─┐
Player ───────┼──▶ Level (logic) ──read every frame────▶ Level3DView
Vehicle × n ──┘          │                                   │
                         ├──▶ HUD, touch controls            ▼
                         └──▶ 2D board (hidden)          3D models
```

| Part | Details |
| --- | --- |
| Activation | An option in Settings, and only if the build includes the 3D module. Builds without 3D never load the 3D scripts |
| Mapping | 1 tile = 1 meter; column → x axis, row → z axis |
| Models | Built from basic shapes: Masbro (hat, backpack, glasses, package, helmet), vehicles, rafts, hazards, items, stalls, houses, warehouse, poles, trees. Toon materials with rim light and outlines |
| Effects | Effect words and speech bubbles become 3D text; 2D particles become 3D particle bursts with the same colors and directions |
| World | Procedural sky and a sun with shadows; in the rain there's fog, rain particles, and vehicle headlights |
| Camera | 50° perspective, 8 m high, 8.5 m behind, angled to the right (3/4 view) |

## Player scenarios

| # | Scenario | What happens |
| --- | --- | --- |
| S1 | Turn on 3D View, then start a day | The 2D board is replaced by a 3D world; HUD and controls stay the same |
| S2 | Set off without a package | A spinning package floats above the stall with the word PICK UP |
| S3 | Pick up the package | The package appears on top of Masbro's backpack |
| S4 | Get hit | "BRAK!", particles, Masbro flips, the camera shakes |
| S5 | Fall into the river | "BYUR!", a splash of water, back to the bank |
| S6 | Rainy day | Fog, rain, vehicle headlights on |
| S7 | Reach the destination | Result card and confetti, same as the 2D version |
| S8 | Turn the option off | The next day goes back to 2D |

## Performance

On the test desktop, 3D View runs at about 55–60 FPS. On phones and mobile browsers, real-time shadows are disabled.

## Next stages

| Stage | Work |
| --- | --- |
| 3D-1 | Test on reference phones (FPS, heat, battery) and optimize |
| 3D-2 | Replace basic-shape models with `.glb` models made by the 3D team |
| 3D-3 | Rigged Masbro animations: idle, hop, flip, fall in the river, celebrate |
| 3D-4 | Separate the board data model from the view for cleaner code |
| 3D-5 | Camera options and readability testing with new players |
| 3D-6 | Cutscenes and shop in 3D |
| 3D-7 | ✅ Web build with 3D (done in v0.12) |

If 3D doesn't pass testing on the reference phones, the 2D version stays the main view and 3D remains a beta option on desktop.
