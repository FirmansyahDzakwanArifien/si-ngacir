---
title: Game Design
description: A summary of the Si Ngacir Game Design Document. Concept, unique selling point, core loop, package system, ratings, and level design.
---

This page summarizes the Si Ngacir **Game Design Document (GDD)** written by Varmintz KW Studio.

## Overview

| | |
| --- | --- |
| **Name** | Si Ngacir — *"Trobos Ajalah"* |
| **Genre** | 2D Arcade / Casual |
| **Elements** | Delivery, road crossing, obstacle avoidance, package management, time challenge, customer rating, level progression |
| **Players** | Single player |
| **Platforms** | Web, Windows, Android |
| **Target audience** | Casual players who enjoy simple, easy-to-grasp games with challenges based on reflexes and decision-making |
| **Inspiration** | *Varmintz Deluxe* (GameHouse), 2000s-era road-crossing and obstacle-avoidance games, combined with a courier game concept |

## What makes it unique

> Si Ngacir turns the lives system into **package condition**. Players aren't just trying to reach the destination; they have to make sure the item they carry stays in good shape. Each level brings a different kind of package, and that package's traits change how the player plays.

The capybara is the *visual hook*; **the package as the main resource** is the core of the gameplay.

## Core gameplay loop

```text
Pick Up Package → Cross → Avoid Vehicles/Hazards
     → Protect Package Condition → Reach Destination → Get Rating
```

```text
MAIN MENU → ACCEPT ORDER → PICK UP PACKAGE → DELIVERY
                                                │
                                         Collision? ── no ────┐
                                                │ yes         │
                                         Package damaged      │
                                                │             │
                                      Destroyed? ── no ───────┤
                                                │ yes         │
                                      DELIVERY FAILED         ▼
                                                   DESTINATION REACHED
                                                            │
                                                     CUSTOMER RATING
                                                            │
                                                      PAY / RESULTS
                                                            │
                                                        NEXT DAY
```

## Package & damage system

The package replaces the concept of health. Collisions don't kill the character; their main impact is reducing the package's condition.

| Damage | Package condition | Status |
| --- | --- | --- |
| 0 | Package safe | Good |
| 1 | Minor damage | Minor Damage |
| 2 | Moderate damage | Damaged |
| 3 | Package destroyed | Failed Delivery |

Sources of damage: hitting vehicles, falling into potholes, falling into the river, and other hazards in the level. Final values were tuned through playtesting: the fritters survive 4 damage, the Crystal Orange Statue only 2, and the heavy birthday cake & betta tank slows your steps.

## Rating system

On arrival, players don't just see a *LEVEL COMPLETED* message; they receive a **Customer Rating** based on package condition, delivery time, and number of collisions, complete with a funny customer comment.

| Rating | Condition | Sample comment |
| --- | --- | --- |
| ★★★★★ | Intact and fast | "Chill face, flawless package. Awesome!" |
| ★★★★ | Slightly damaged | "The package is a bit dented, but still fine." |
| ★★★ | Some damage | "Be more careful next time, Masbro." |
| ★★ | Fairly bad | "The package is a bit wrecked, but what's inside still works." |
| ★ | Almost totally ruined | "Is this a package or cargo from a shipwreck?!" |
| 💥 | Destroyed | "Masbro... where's my package?" |

## Level design

| Level | Name | Package | Focus |
| --- | --- | --- | --- |
| 1 | Introduction | Hot Fritters | Introduces moving, crossing, collisions, and delivery; an impatient customer |
| 2 | Heavy Delivery | Birthday Cake & Betta Tank | Adjusting timing to slower steps |
| 3 | Time Pressure | Ice Cream | The tightest ETA through alleys full of potholes |
| 4 | Traffic Challenge | VIP Laptop | More and faster vehicles in a storm, combined hazards |
| 5 | Final Delivery | Crystal Orange Statue | Combines movement, timing, dodging, package management, and route choice |

The packages and day titles follow the Story Writer team's Kedai Chill script (see [The Five Days](/en/bermain/hari/)).

## Audio & visuals

- **Visuals:** simple, colorful, easily readable 2D casual arcade. Players must quickly tell apart Masbro, the package, vehicles, hazards, the destination, and damage status.
- **Music:** light and playful, with special themes for sad and tense moments in cutscenes.
- **Sound effects:** footsteps, package pickup, vehicles, collisions, package damage, arrival, rating stars, and rewards. The package-damage and rating sounds are deliberately a bit over the top to boost the humor.

## From GDD to game

Some GDD ideas that have been realized and expanded on:

| Idea in the GDD | In the game |
| --- | --- |
| Capybara customization if scope allows | [Masbro's Shop](/en/fitur/toko/) with 12 accessories, including the free Head Orange |
| Side characters besides Masbro | Boss Koko, Nana, Kuro, Pak Buldog, the Landlord, Mr. Mayor, and the street folk |
| Enemies and hazards | Kuro and his banana peels, Pak Buldog, street cats, rain, potholes, rivers |
| Retry / Return to Menu options | Plus **Continue from Checkpoint** |
