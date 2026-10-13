---
tags: [decision]
status: accepted
date: 2026-10-13
---
# 0002 — Build GUIs and world in the place, script only behavior

## Context
The developer wants to edit and visualize GUIs, maps and models by hand in Studio.
UI and geometry that only exist because a script generates them at runtime can't be
seen or tweaked in the editor.

## Decision
- GUIs are built as real ScreenGuis in `StarterGui`; maps and props in `Workspace`;
  reusable models/templates in `ReplicatedStorage.Assets` / `ServerStorage.Assets`.
- These are built **before** the scripts that use them (by hand, or by Claude via
  `execute_luau` in the Edit datamodel so they're saved in the place).
- Scripts find existing instances and add behavior. Repeated items are cloned from
  templates built in Studio, not constructed with `Instance.new`.
- Gameplay parts are marked with CollectionService tags; per-instance tunables use
  Attributes so they're editable in the Properties panel.

## Alternatives considered
- **Code-generated UI/world** (e.g. building UI with `Instance.new` or a declarative
  UI library) — easier to diff, but invisible in the editor and hard to hand-tune.

## Consequences
- Scripts depend on instance names/paths; each system's note in `02 Systems/` lists
  what it expects to exist, and renaming in Studio must be reflected there.
- Truly procedural content (projectiles, particles, procedural terrain) is still
  generated in code, with the reason documented.

Related: [[Home]] · [[0001-studio-first-with-studio-mcp]]
