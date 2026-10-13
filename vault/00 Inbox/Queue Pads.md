---
tags: [feature, hub, matchmaking, party, m2]
status: proposed
updated: 2026-10-13
---
# Queue Pads — a physical party lobby in the hub

> **Status: proposed.** The developer asked for this on 2026-10-13, as a roadmap item and
> not urgent. It's the *physical* way to form a party in the hub. It overlaps the M2 plan's
> **Party pod** (an invite and quick-join menu, `PartyService` + `PartyGui`) in
> [[Loop (M2)]]. Decide whether pads **replace** that menu or **sit alongside** it before
> M2's hub sessions start (see Open questions).

## Summary
Players form a squad by **standing on the same pad** in the hub. Each pad shows its
headcount and a countdown. When the countdown ends, or the pad fills, everyone on it
teleports together into a reserved Run server ([[0004-single-place-hub-and-run-modes]]).
No menus are needed: you see who's going, walk over to join, and walk off to leave. It's
the familiar Roblox "elevator / queue pad" pattern, and it suits the hub train as a place
you walk around in (GDD: the hub "doubles as the party lobby").

## Player experience
1. In the hub, you walk up to a row of **boarding pads** at the hub train's edge.
   - *Theme idea:* each pad is a **handcar on a siding**. When it departs, it rolls off
     toward the hostile train.
2. Step on a pad and it lights up in your player colour. Its sign reads **"2/4 · 12s"**.
   Your screen shows **"BOARDING… 12"** and a **LEAVE** button.
3. Friends walk onto the same pad. When it fills, the countdown drops to a short final
   one.
4. At 0 there's a **"ALL ABOARD!"** pop. The handcar departs, a teleport screen shows,
   and everyone arrives in the same run.
5. Step off, or press LEAVE, to drop out at any time before departure.

## Rules & numbers (first guesses)
- **Pads:** about 4 squad pads with **Capacity 4**, plus 1 **solo pad** (Capacity 1)
  that replaces the PLAY SOLO button.
- **Countdown:** it starts when the first player steps on: **15 s**. When the pad fills
  it drops to **3 s**. If the pad empties, it resets.
- **Membership is decided by the server:** a player is on a pad if their root is inside
  the pad's zone box. The server checks this at about 10 Hz, like the weapon crates
  ([[PickupService]]), rather than trusting `Touched`. A player can be on one pad at a
  time.
- **LEAVE:** a client request (validated and rate-limited, [[Guard]]). The server moves
  the player just off the pad, so they don't rejoin at once.
- **Departure:** the pad's roster becomes the party. It follows the M2 teleport flow:
  reserve a server, write the MemoryStore record `{ mode = "Run", partyUserIds }`, then
  teleport ([[0004-single-place-hub-and-run-modes]]). If the teleport fails, the players
  go back onto the pad and the countdown restarts.
- **Co-op scaling** uses the pad's headcount at departure (`COOP_SCALE`).
- Pads only match players **in the same hub server**. Cross-server quick-join stays a
  later item.
- Squad select (the Barracks pod) happens **before** queueing. While you're on a pad,
  changing squad is allowed until departure.

## Systems involved
- **Server:** a `QueuePadService` (or part of the planned `PartyService`), the M2
  `TeleportFlow`, and [[Guard]].
- **Client:** a `QueuePadController` (the pad's sign, your queue panel and the LEAVE
  button), plus the loading/teleport screen from M2.
- New remote: `RequestLeavePad` (no payload, 2/s).
- Workspace attributes or pad attributes carry the state for clients: `Count` and
  `DepartsAt`.

## Studio build list
_Build these in the place before scripting (`CLAUDE.md`)._
- [ ] `Workspace.Map.Hub.QueuePads`: pad Models tagged `QueuePad`. Each has:
  - attributes `Capacity`, `Countdown`, `FullCountdown` and `Mode` (`"Run"`),
  - a `Zone` part (invisible, non-colliding) that sets the membership box,
  - a hand-built `BillboardGui` sign (`CountLabel`, `TimerLabel`),
  - a light or neon part that the controller tints.
- [ ] `StarterGui.QueueGui`: a "BOARDING… n" panel and a LEAVE button (touch target
  ≥ 48 pt).
- [ ] The handcar departure is a visual only; the teleport does the real move.

## Art & audio needs
- A handcar or boarding-platform model in the Wild West palette ([[Art Direction]]).
- A bell or whistle on departure, a click when stepping on, and a countdown tick.

## Open questions
- **Replace or add?** Should pads **replace** the M2 Party pod's invite and quick-join
  menu, or sit **alongside** it?
  - *Recommendation:* pads become the main way to form a party (they're simpler to
    build, more social, and easy on mobile).
  - Friends who aren't in the same server can still use Roblox's own join and invite
    features to get into your hub server first. That would cut `PartyGui`'s invite flow
    from M2.
- Should a pad be **lockable** (friends only, or a private pad for a group)? *Proposed:*
  not at first.
- Should players who are AFK on a pad be removed? *Proposed:* yes, after 60 s with no
  input.

## Implementation notes
- _Not built. In M1, the Run-mode staging platform and READY button
  ([[RunStateService]]) are the stand-in._

Related: [[Loop (M2)]] · [[Game Design Document]] · [[0004-single-place-hub-and-run-modes]] · [[Home]]
