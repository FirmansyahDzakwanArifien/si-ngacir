---
title: Rules & Pay
description: The pickup-and-delivery flow, package condition instead of lives, the ETA Timer, the pay formula, and customer ratings.
---

## A day's flow

1. Masbro sets off from the **Ngacir Express Warehouse** (bottom of the screen) **without a package**.
2. **Pick up the package** at the **sender's stall**, roughly halfway along the route. Look for the floating package icon labeled **PICK UP** (AMBIL), then step onto the stall's tile. <img class="sprite" src="/img/sprites/pickup_stall.svg" alt="Sender's stall" />
3. **Deliver the package** to the **customer's house** at the top end of the route.
4. The customer gives a **rating**, then the day's pay goes into your savings.

Before you pick up the package, collisions and falling into the river just knock Masbro back; the package can't be damaged yet. Reaching the customer's house without the package doesn't count as finishing.

The route is much longer than one screen, and the view scrolls upward as you go. **The road layout is randomly regenerated every time a day starts**, and the closer you get to the customer's house, the faster the vehicles.

## Package = lives

Masbro has no lives. What you protect is the **package**. Every collision damages the package, knocks Masbro back one step, and gives him a moment of invulnerability (he blinks). If the package is destroyed, the delivery fails and that day's pay is forfeited as compensation.

| Vehicle | Speed | Package damage |
| --- | --- | --- |
| <img class="sprite" src="/img/sprites/vehicle_motor.svg" alt="" /> Motorbike | Fast | 1 |
| <img class="sprite" src="/img/sprites/vehicle_mobil.svg" alt="" /> Car | Medium | 1 |
| <img class="sprite" src="/img/sprites/vehicle_truk.svg" alt="" /> Truck | Slow, long | 2 |

Fragile packages like eggs take double damage.

## Game screen

| Element | Meaning |
| --- | --- |
| **DAY** | Which day of the probation you're on |
| **Package boxes ■■■** | Package condition. One box disappears each time the package is damaged. All gone means the package is destroyed |
| **Route bar** | Yellow dot = Masbro, brown box = pickup stall, red house = destination |
| **ETA** | Time left on the target. Turns yellow at ≤10 seconds, red "LATE" once it runs out |
| **PICK UP AT / TO** | Your current goal: the sender's stall before pickup, then the customer's name |

## ETA Timer

Arrive before the ETA runs out to earn the **on-time bonus**. Being late doesn't fail the delivery, but your pay is cut for every second you're late. The ETA already accounts for the stop at the stall.

## Daily pay

```text
Pay = Base pay + On-time bonus (+ Tip) (+ Coin bonus)
      − Damage fines − Late deduction
```

Each day's pay is added to the **treatment savings**. If you replay a day, your **best** pay for that day counts. Savings target: **Rp350,000**.

| Day | Base pay | On-time bonus | Fine per damage | Late deduction per second |
| --- | --- | --- | --- | --- |
| 1 | Rp50,000 | Rp20,000 | Rp10,000 | Rp500 |
| 2 | Rp60,000 | Rp20,000 | Rp15,000 | Rp750 |
| 3 | Rp70,000 | Rp25,000 | Rp20,000 (2x for Pak Ojan) | Rp1,000 |
| 4 | Rp80,000 | Rp25,000 | Rp20,000 | Rp1,000 |
| 5 | Rp100,000 | Rp30,000 | Rp30,000 | Rp1,500 |

## Customer ratings

Once the package arrives, the customer gives 1–5 stars and a comment based on the package's condition and punctuality.

| Stars | Sample comment |
| --- | --- |
| ★★★★★ | "Package in one piece, courier totally chill. Recommended!" |
| ★★★★ | "Package is a bit dented, but still fine." |
| ★★★ | "Be careful when you deliver, Masbro." |
| ★★ | "Masbro... the package is damaged, but I'll take it." |
| ★ | "Dude... did this package just come back from a war?" |

## Winning and losing

- **Success:** reach the customer's house before the package is destroyed. The flow: Delivery Complete → Rating → Pay → next day.
- **Failure:** the package is destroyed. Choose **Retry Day**, return to the menu, or **Continue from Checkpoint** if you've passed one (see [Hazards & Items](/en/bermain/rintangan/#checkpoints)).
