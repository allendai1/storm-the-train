---
tags: [design, feature, milestone, m2, spec, checklist]
status: planned
updated: 2026-10-16
---
# Loop (M2) — spec and Studio build checklist

> **Status: planned.** This turns milestone **M2 (Loop)** from the [[Game Design Document]] into a checklist that continues from [[First Playable (M1)]] (sessions
> 7–13). M2 is: **hub train, next-train leap, checkpoint, agent swap, Mayhem and
> gadgets, coins and saving.** It assumes M1 is built and its playtest questions are
> answered. **Revisit every first-guess number with what M1 taught.** Nothing here is
> built yet.

## Summary
M2 turns one train into the real **run loop**:
1. Players gather on the **hub train** (Hub mode), form a party on a **queue pad**
   ([[Queue Pads]]) and teleport into a
   **reserved Run server** ([[0004-single-place-hub-and-run-modes]]).
2. They fight through **legs of 3 trains**, **leaping** from engine to caboose
   between trains.
3. The **hub train pulls alongside** at each checkpoint: a free full heal, then a
   **majority vote** to continue or cash out.
4. Players **swap** between Max and Brick, fill their **Mayhem ring** and deploy
   **gadgets**.
5. They earn **score and coins**, which are **saved** with ProfileStore.

Bosses, hostages, survival, more enemies and agents (M3) and the shops and blueprints
(M4) are still out.

## Scope
| In M2 | Still later |
|---|---|
| Hub mode: `Map.Hub` hub train, Barracks pod (squad select), **queue pads** (squad pads plus a solo pad, [[Queue Pads]]) | Armory, Surplus, Missions and Store pods (M4); they're built as closed pods ("COMING SOON") |
| Teleport to a reserved Run server, then back to the hub. Party roster in MemoryStore | Cross-server quick-join (later) |
| Endless runs: **legs of 3 trains**, leaps, a run-long difficulty ramp | Boss every 2nd leg, hostage, survival (M3) |
| Leg layout: Normal, Normal, **Thief train** (placeholder for the event slot) | Real event rotation (M3) |
| **Checkpoint:** hub checkpoint train, free full heal, **majority vote**, Brick granted on the first one | Boosters at checkpoints (M4) |
| **Agent swap:** Max + Brick (free) | Turbo, Nana, Mimi, Gleep (M3) |
| **Mayhem ring** plus gadget fan. Gadgets: Turret Drone, Melee Drone, Defender Drone, **Melee Suit (Brick's Heavyweight)**, Air Strike | Other drones and mechs (M3) |
| **Score and combo** ([[Score and Combo]]), run-end screen with squad score | Leaderboards (M4) |
| **Coins:** gap coins, drops, the run-end score bonus, committed at checkpoints | Spending coins (M4) |
| **Saving:** ProfileStore, schema v1 subset | Gems, purchases, receipts (M4) |
| Writing: announcements, barks and tutorial beats for M2 systems ([[Writing and Dialogue]]) | Mission and challenge systems (M4) |

## Rules & numbers
### Run structure (decided in the GDD, numbers are first guesses)
- **Legs of 3 trains.** Trains 1 and 2 are normal. Train 3 is the **event slot**. In
  M2 that's always a **Thief train**: a normal train with 2 blueprint thieves (still a
  stub, counted and not saved). Bosses take over every 2nd leg's event slot in M3.
- **Difficulty ramps across the whole run.** The spawn timeline runs on the run's
  **combat time**, which pauses during leaps and checkpoints.
  - Train 1 uses the M1 table.
  - Each later train continues from the plateau, with the **alive-cost cap +10% per
    train** (up to 2× the train-1 cap) and the **wave interval −5% per train** (down to
    2 s at minimum).
  - Bart recurs on every train after the first.
- **Train clear** works as in M1: the train's timeline segment is done, no enemies are
  alive, and someone is on the engine roof. Then **"NEXT TRAIN — LEAP!"**.

### Leaping between trains
- The next train is built ahead along +X, after a **10-stud leap gap**
  ([[0009-static-trains-scrolling-world]]). At 28 studs/s with an 8-stud jump, a
  running jump covers about 16 studs, so the leap is easy for every agent. **Brick at
  20 studs/s covers about 11 studs, so check his leap in playtests.**
- **Gap coins:** an arc of about 20 personal coins over the leap gap (the original's
  "coins in the gap").
- **Falling** into the leap gap follows the gap-fall rule ([[0005-side-on-movement-and-camera]]).
- The old train is destroyed once every living player has crossed. A downed or
  spectating player is moved across.

### Checkpoint (after every 3rd train)
- The **hub checkpoint train** (template `HubCheckpoint`) arrives like a next train.
  Leaping onto it shows **"HUB TRAIN ALONGSIDE!"**.
- **Free full heal** for everyone on arrival, from the medbay ([[Economy and Monetization]]). Downed and spectating players come back at full HP.
- **Commits:** run coins and stats are saved ([[0008-player-data-profilestore]]).
  Blueprint banking arrives in M4.
- **First checkpoint ever:** Brick is granted, and the swap tutorial plays
  ([[Writing and Dialogue]] §6).
- **[decided] Continue or cash out is a majority vote** of the players in the run.
  - **[decided 2026-10-16]** A **tie means continue**. The vote ends when **everyone has voted**.
  - Cash out sends the whole party to the run-end screen, then back to the hub.
- **[decided] There's no checkpoint timer.** The train waits for every vote.
  - **[decided 2026-10-16] AFK safeguard:** a player with no input for **90 s** at a checkpoint
    is counted as **"Continue"** and shown as "AWAY". Roblox's own idle kick still
    applies after 20 minutes.
- While at the checkpoint, players can walk the checkpoint train. The **Barracks pod**
  lets them change squad order. The other pods are closed until M4.

### Agent swap
- **Swap** with Q/E, LB/RB, or a swipe or swap button. The **1.5 s cooldown** keeps
  your HP, position, Mayhem and combo ([[Launch Agents]]). There's no swapping while
  in a mech suit.
- Each agent **remembers its active weapon**. Weapon crates switch the current
  agent's weapon only.
- **Brick** (first guesses from [[Launch Agents]]):
  - 20 studs/s, toughness 0.20, spin level 6 (9 damage, 6-stud radius).
  - **Perk:** 0.5 Mayhem per point of raw damage taken.
  - **Scattergun:** 5 pellets × 12 damage (16 within 6 studs), 10° spread, range 14,
    every 0.45 s.
  - **Crowd Pleaser:** 6 damage every 0.07 s after a 0.6 s spin-up, range 40.
- **Dev flag:** an Attribute `DevGrantAllAgents` on `ServerScriptService.Server`, to
  test 3-agent squads with greybox agents. Studio only.

### Mayhem and gadgets ([[Gadgets and Mayhem]])
- **The meter:** 0–100 per player. Fill: light knockout 4, mid knockout 20, ×1.5 for a
  spin knockout, assists at 50%. It doesn't decay, and it's kept across swaps and trains.
- **[decided] HUD:** your **Mayhem ring** sits on the left edge and glows when full.
  The **gadget fan** opens from it (1/2/3, the D-pad, or tapping the ring).
  Teammates' rings around their portraits glow when they're ready ([[Art Direction]]
  §10).
- **M2 gadgets:**

  | Gadget | Agent | Duration (L1) | M2 numbers (first guess) |
  |---|---|---|---|
  | Turret Drone | Max | 30 s | 8 damage / 0.25 s, 25-stud range |
  | Melee Drone | Max | 30 s | 15 damage / 0.6 s |
  | Defender Drone | Brick | 51 s | Blocks projectiles for you and teammates behind you |
  | Melee Suit ("the Heavyweight") | Brick | 15 s | 200 armour, 23 studs/s, foam-finger arms 12 / 0.1 s with knockback, body slam; 200-damage entry stomp in a 6-stud radius (half to bosses) |
  | Air Strike | Max, Brick | — | 3 s countdown, 200 damage along the carriage, **one per party** |

- **Lock rules:** one drone per player, no gadget while in a mech, one Air Strike per
  party, and nothing between trains or at checkpoints.

### Score, combo and coins
- Score and combo follow [[Score and Combo]]: knockout points × a personal combo (up to
  ×6), plus flat bonuses for clearing trains, Untouchable, revives and leaps. The squad
  score is the sum.
- **Coins:** gap coins (about 20 per leap), drops (lights 5%, 1–3 coins; mids 100%,
  10–20), and the **run-end bonus of 1 coin per 25 points of personal score**. Coins
  are always kept, whether you cash out or wipe. They're committed at each checkpoint
  and at run end.
- The target is about **2,000 coins per average 12-minute run** ([[Economy and Monetization]]). Measure it in M2.

### Saving (ProfileStore, schema v1 subset)
- **Fields:** `SchemaVersion`, `Coins`, `OwnedAgents` (Dash; Brick after the first
  checkpoint), `Squad`, `Bests` (`SquadScore`, `IndividualScore`, `FurthestTrain`),
  `Stats` (runs, trains cleared, knockouts, revives), `Tutorial` (`TrainingDone`,
  `FirstCheckpointDone`, `FirstMayhemDone`).
- The other schema fields from [[0008-player-data-profilestore]] are added with
  migrations in M4.

## Studio build list (continues from M1's sessions 1–6)
> **[decided 2026-10-16] Paused after Session 11.** The [[Feel and Look (Slice)]] comes next.
> Sessions 7, 12 and 13 resume after it. Their code is already drafted.

### Session 7 — Saving
Draft code, install and verify steps: [[Session 7 PlayerDataService Code]] (written
2026-10-16 in a cloud session and not run yet).
- [ ] Install **ProfileStore** into `ServerStorage.Packages`. Record its version in
  [[Packages]].
- [ ] **`PlayerDataService`:** load on join, release on leave and on `BindToClose`,
  schema v1 subset, migrations scaffold. Use the mock store in Studio.
- [ ] Mirror profile data the client needs into **Attributes** (`Coins`, `OwnedAgents`
  as a JSON string or a folder).

### Session 8 — Score, combo, coins
- [x] **`ScoreService`:** knockout points, combo timer (2.5 s), multiplier tiers,
  assists, flat bonuses. Player Attributes `Score`, `Combo`, `ComboMultiplier`.
- [x] **Coin pickups:** the template `ReplicatedStorage.Assets.Pickups.Coin` and the
  gap-coin arc. Drops through `PickupService`, collected by server proximity.
- [x] Update the **HUD** with the score and combo badge and the coin counter, and the
  **run-end screen** with the squad score, per-player rows with callouts, and coins
  (the Figma run-end mockup).

### Session 9 — Multi-train runs, leaps, checkpoints
- [x] **`TrainService`:** build the next train ahead with the leap gap, destroy the old
  train, and handle the leg structure and the Thief train.
- [x] **Spawn timeline continuity** across trains, with the per-train ramp.
- [x] **Checkpoint train template** `ServerStorage.Assets.Trains.HubCheckpoint`:
  Medbay, Barracks pod, and closed pods for Armory, Surplus and Missions. Built by hand
  in the Agency's navy and gold ([[Art Direction]] §6).
- [x] **`CheckpointService`:** arrival, heal, commits, first-time Brick grant, majority
  vote (tie = continue), AFK safeguard, departure.
- [x] **GUIs:**
  - `CheckpointGui`: vote buttons, each player's vote state, and the "waiting for…"
    list,
  - an update to `HudGui`'s train progress ("LEG 2 · TRAIN 2/3", next event).
- [x] **Remote:** `RequestCheckpointChoice` (`"Continue" | "CashOut"`), validated and
  rate-limited ([[0007-networking-and-remotes]]).

### Session 10 — Agent swap and Brick
- [x] **Agent template** `ReplicatedStorage.Assets.Agents.BrickBroadsley` and weapon
  templates `Scattergun` and `CrowdPleaser`.
- [x] **`SquadService`:** swap with cooldown, the per-agent active weapon, and stats
  re-applied on swap (WalkSpeed, toughness, hitbox).
- [x] **HUD squad strip** (3 portraits; the active one highlighted). **Remote:**
  `RequestSwap(direction)`.
- [x] Barracks pod **squad select** GUI, following the Figma mockup. It uses
  `EquipSquad`, validated against `OwnedAgents`.

### Session 11 — Mayhem and gadgets
- [x] **`MayhemService`:** the meter and its fill sources, and the perk hook for Brick.
- [x] **`GadgetService`:** `RequestGadget(slot)` validation, the lock rules,
  durations, and despawning.
- [x] **Drone templates** in `ReplicatedStorage.Assets.Drones`: TurretDrone,
  MeleeDrone, DefenderDrone. Each has Attributes per [[Gadgets and Mayhem]].
- [x] **Mech template** `ReplicatedStorage.Assets.Mechs.Heavyweight`. Armour,
  ejection, entry stomp, and no swapping while suited.
- [x] **Air Strike:** marker and planes in `Assets.Effects`, a server sweep along the
  carriage, one per party.
- [x] **HUD:** the **Mayhem ring** (yours on the left edge, plus teammate rings) and
  the **gadget fan**, from the Figma components `HUD/MayhemRing` and `HUD/GadgetSlot`.

### Session 12 — Hub mode and teleport
Draft code, setup script and verify steps: [[Session 12 Hub Code]] (written 2026-10-16 in
a cloud session and not run yet).
- **[decided 2026-10-16] The hub is side-on, like the runs:** the same agent rig, controls and camera.
  The Falcon-8 is a long train you walk along, with the pods and queue pads in a row.
- **[decided 2026-10-16] After a run, the results screen offers BACK TO HUB, and PLAY AGAIN is
  removed.** The server waits until everyone has pressed it, or for 30 s. Then the party
  returns together to one reserved Hub server (a solo player goes to a public hub). In
  Studio, where teleports can't work, it falls back to the old PLAY AGAIN reset.
- [ ] **`Workspace.Map.Hub`:** the walkable hub train, with the Barracks pod, the
  **queue pads** (`QueuePads`, tagged `QueuePad`; see [[Queue Pads]] → Studio build list)
  and the closed M4 pods.
- [ ] **`QueuePadService`:** pad membership by server zone checks, the countdowns, LEAVE
  (remote `RequestLeavePad`), and departure → teleport flow. It replaces the old
  `PartyService` invite menu and PLAY SOLO (decided 2026-10-13).
- [ ] **Teleport flow:**
  1. `ReserveServer` gives an access code and a private server ID.
  2. Write the MemoryStore record `{ mode="Run", partyUserIds }`.
  3. Call `TeleportAsync` with a loading screen and retries.
  4. The run server checks the roster.

  After the run, the party goes back to a reserved **Hub-mode** server, or solo
  players to a public hub.
- [ ] **GUIs:** `QueueGui` ("BOARDING… n" and LEAVE), each pad's hand-built sign, a
  loading or teleport screen, and the Hub HUD (coins). The Figma Party Lobby screen is
  dropped.

### Session 13 — Full-loop playtest
- [ ] **Publish a test place.** Teleports and reserved servers don't work in Studio
  play. Playtest a 2–4 player run over at least **2 legs**.
- [ ] **Measure:**
  - run length (target 10–15 min),
  - coins per run (target about 2,000),
  - Mayhem fill time (target 45–60 s),
  - performance with drones, a mech and the Air Strike on screen.
- [ ] Record the tuning changes here and in the related notes.

## Systems involved (create notes in `02 Systems/` as each is built)
- **Server, new:** PlayerDataService, ScoreService, CheckpointService, SquadService
  (extended), MayhemService, GadgetService, QueuePadService, TeleportFlow (part of
  ModeService).
- **Server, extended:** TrainService, SpawnService, PickupService.
- **Client:** CheckpointController, SquadController, MayhemController (ring and fan),
  QueuePadController, LoadingController, plus updates to HudController.

## Playtest questions (what M2 must answer)
1. Does a 2-leg run (about 15 min) keep its energy? Is the per-train ramp right?
2. Do leaps feel good, and does Brick clear them?
3. Is the checkpoint vote clear? Does "no timer + AFK safeguard" work, or does the
   squad wait too long?
4. Does swapping Max ↔ Brick feel meaningful?
5. Does Mayhem fill about every 45–60 s? Is the gadget fan quick to use on mobile?
6. Is the Heavyweight a satisfying moment? Are its 200 armour and 15 s right?
7. Are coin earnings near the target? Do saves and teleports survive leaving,
   rejoining and server shutdowns?

## Open questions
- ~~A **tie = continue** rule for the vote, and the **90 s AFK safeguard**: OK?~~
  **[decided 2026-10-16] Yes**, both as written above.
- ~~Should a player who **joins mid-run** be possible at all?~~ **[decided 2026-10-16] No.**
  Run servers are locked to the party roster. A player who leaves can't be replaced
  mid-run.

## Implementation notes
- **Session 8, 2026-10-14: done, except gap coins** (they need leaps, Session 9).
  - Built: the `Points`, `CoinChance`, `CoinMin` and `CoinMax` attributes on the enemy
    templates; the `Pickups.Coin` model; the HUD `ScorePanel` (score, coins, combo badge
    with a timer) and `BonusPop`; and the run-end squad score, Score/Coins columns and
    callouts.
  - Systems: [[ScoreService]], plus coins in [[PickupService]].
    - [[CombatService]] got `onKnockout` (killer, damagers, source) and
      `onPlayerDamaged` hooks. Sessions 9–11 reuse them.
    - [[RunStateService]] got the run-end coin bonus, the squad score and callouts.
  - Decisions made while building:
    - coins are **personal loot**: each player collects each coin once, so the coin
      target is per player,
    - run coins are the attribute `RunCoins`; saving comes in Session 7,
    - callouts are TOP SCORE, MOST KOs, MEDIC and COLLECTOR, at most one per player.
- **Session 9, 2026-10-14: done.**
  - Built: the `HubCheckpoint` train (Medbay and Barracks pods plus 3 closed pods, as a
    backdrop behind the walkway), `CheckpointGui`, and the remote
    `RequestCheckpointChoice`.
  - Systems:
    - [[TrainService]]: `buildNext`, `PreviousTrain` and `dropPrevious`,
    - [[SpawnService]]: per-train timelines, the Plateau ramp and Thief trains,
    - [[RunStateService]]: the leap, checkpoint and vote states. The planned
      `CheckpointService` is folded in here,
    - helpers `CharacterService.placeNear`, `SquadService.heal` and
      `PickupService.resetCrates`,
    - CheckpointController,
    - the HUD title "LEG n · TRAIN k/3 · NEXT: …".
  - Decisions made while building:
    - later trains play a 60 s Plateau (the duration is a first guess),
    - train 1 no longer has the M1 blueprint thief (thieves are the Thief train's event),
    - every new train resets crates and the primary weapon,
    - bled-out players stay out until the checkpoint heal.
  - Verified with one player: all of Leg 1 → checkpoint (heal, vote UI) → CONTINUE →
    Leg 2. Details are in [[RunStateService]].
- **Session 10, 2026-10-14: done.**
  - Built: the `BrickBroadsley` agent and the `Scattergun` and `CrowdPleaser` weapons;
    `SquadGui` (Barracks); the HUD `SquadStrip` and `TutorialHint`; the touch
    `SwapButton`; and the remotes `RequestSwap` and `EquipSquad`.
  - Systems:
    - **[[AgentService]]** (the spec's "SquadService" — renamed, because that name is the
      revive service) plus SquadController,
    - `CharacterService.swapTo`,
    - pellets, spin-up and per-agent spin in [[CombatService]].
  - **Controls now match the GDD:** Space = jump, W/↑ = Interact, Q/E = swap.
  - Verified with one player:
    - Brick was granted at the first checkpoint and E swapped to him,
    - the Barracks re-ordered the squad,
    - **cash-out** → CASHED OUT! results (Session 9's open item),
    - Scattergun 5 pellets / 0.45 s, Crowd Pleaser 0.6 s spin-up then 0.07 s.
  - Fixed: Humanoid automatic scaling had been re-scaling the pre-scaled rigs (Brick, Bart)
    and their hitboxes.
- **Session 11, 2026-10-14: built, partly verified.**
  - Built:
    - the Turret, Melee and Defender drones, the Heavyweight mech, and the Air Strike
      marker and plane,
    - the HUD Mayhem ring, gadget fan, active-gadget readout and teammate rings,
    - the remote `RequestGadget`,
    - [[GadgetService]] + MayhemService + MayhemController,
    - CombatService hooks: the damage filter (armour, invulnerability), projectile
      blockers (Defender), `isFiring` and `SpinKnockback`.
  - Verified: the ring and fan appear at full Mayhem, and key 2 deployed the Melee Drone,
    which fought and refilled Mayhem.
  - Found and fixed: the Backpack hotbar was swallowing key 1, so it's disabled.
  - **Not verified yet** (Studio's playtest start hung): the Turret, Defender, Heavyweight,
    Air Strike and lock messages. The list is in [[GadgetService]].
  - Simplifications: the ring fills from the centre (no arc yet), and the mech has no heavy
    gravity.

Related: [[First Playable (M1)]] · [[Game Design Document]] · [[Gadgets and Mayhem]] · [[Score and Combo]] · [[Economy and Monetization]] · [[Writing and Dialogue]] · [[0004-single-place-hub-and-run-modes]] · [[0008-player-data-profilestore]] · [[Home]]
