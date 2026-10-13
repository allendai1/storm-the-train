---
tags: [decision]
status: accepted
date: 2026-10-13
---
# 0001 — Studio-first workflow with the Roblox Studio MCP server

## Context
We want AI-assisted development (Claude Code) on the game while keeping Roblox
Studio as the place where the game is built. A file-sync workflow (Rojo) was
considered and rejected as unnecessary overhead for this project.

## Decision
- The Roblox place is the source of truth for all scripts and content.
- Claude Code edits the place through Studio's built-in MCP server
  (`script_read`, `multi_edit`, `execute_luau`, playtest tools, …).
- This git repo holds design knowledge: the Obsidian vault, Graphify output, and
  `CLAUDE.md`.
- Single-script architecture: one server bootstrap loading Services, one client
  bootstrap loading Controllers.

## Alternatives considered
- **Rojo + Wally + Selene/StyLua/luau-lsp** — git-versioned code and CLI lint/typecheck,
  but adds a sync step and toolchain the project doesn't want.

## Consequences
- Scripts aren't versioned in git; Roblox's place version history is the backup, so
  save/publish regularly.
- No CLI lint/typecheck; verification is done by playtesting through MCP and reading
  the console output.
- Claude can only reach Studio from a local Claude Code session, not cloud sessions.
- `02 Systems/` notes are the versioned description of the code and must be kept current.

Related: [[Home]]
