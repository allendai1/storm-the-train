---
tags: [decision]
status: accepted
date: 2026-10-13
---
# 0001 — Rojo file-based workflow

## Context
We want version control, code review, and AI-assisted development (Claude Code) on the
game's code, which Roblox Studio's built-in script storage doesn't support well.

## Decision
- Source lives in `src/` as `.luau` files and is synced into Studio with Rojo.
- Toolchain pinned via Rokit; packages via Wally; Selene + StyLua + luau-lsp as the quality gate.
- Single-script architecture: one server bootstrap loading Services, one client bootstrap loading Controllers.
- Design knowledge in this Obsidian vault; Graphify builds a knowledge graph over vault + code.

## Consequences
- Studio-only assets (maps, models, UI built in Studio) need a deliberate home — either
  saved as `.rbxm` models under version control or kept in the published place.
- Contributors need Rokit installed and the Rojo Studio plugin.

Related: [[Home]]
