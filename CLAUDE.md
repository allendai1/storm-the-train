# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**Train Mayhem** (formerly the working title Train Runner; the repo is named after *Storm the Train*, the 2016
mobile game it's inspired by) is a Roblox experience written in **Luau**. Development is
**Studio-first**: the game, including all scripts, lives in the Roblox place and is
edited directly in Roblox Studio. Claude works on the place through the
**Roblox Studio MCP server** (built into Studio). There is no Rojo and no file sync.

This repository holds the project's knowledge, not its code:

- **Obsidian vault** (`vault/`) — persistent project knowledge: status, design,
  art direction, system notes, decisions, techniques, devlog.
- **Graphify** (`graphify-out/`) — a knowledge graph built over the vault.
- This file and Claude Code settings (`.claude/`).

## Roblox Studio MCP

### Setup (once per machine, by the user)

1. Update Roblox Studio to the latest version.
2. In Studio: **Assistant → … → Manage MCP Servers → Enable Studio as MCP server**.
3. Connect Claude Code, either:
   - **Quick connect** (easiest): in the same panel, expand **Quick connect** and turn on
     **Claude Code**; or
   - **CLI**, from this repo:
     ```bash
     # macOS
     claude mcp add --transport stdio Roblox_Studio -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP
     # Windows
     claude mcp add --transport stdio Roblox_Studio -- cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat
     ```
4. Restart Claude Code, open the place in Studio, and confirm the green "connected"
   indicator in **Manage MCP Servers**.

The MCP server runs locally next to Studio. **It is only reachable from a Claude
Code session on the same machine** — cloud sessions (claude.ai/code, CI) can't see
Studio. In those sessions, work only on the vault/docs and say that Studio changes
must be made from a local session.

### Tools

Every tool takes a `studio_id`. Call `list_roblox_studios` first and confirm you're
targeting the right place (check the place name/ID) before making changes.

| Area | Tools |
|------|-------|
| Scripts | `script_read`, `script_search`, `script_grep`, `multi_edit` |
| Explore | `search_game_tree`, `inspect_instance`, `subagent` (`explore`, `playtest`) |
| Run code | `execute_luau` (`datamodel_type`: Edit, Client, or Server) |
| Playtest | `get_studio_state`, `start_stop_play`, `get_console_output`, `screen_capture` |
| Input sim | `character_navigation`, `user_keyboard_input`, `user_mouse_input` |
| Assets | `search_asset`, `insert_asset`, `generate_mesh`, `generate_material`, `generate_procedural_model`, `wait_job_finished`, `upload_image`, `store_image` |
| Docs | `http_get` (Roblox docs), `skill` |

Read-only tools are pre-approved in `.claude/settings.json` (assumes the server is
named `Roblox_Studio`, as in the commands above); anything that changes
the place (`multi_edit`, `execute_luau`, `insert_asset`, generation, playtest
control) asks for permission.

### How to work in Studio

- **Explore before editing.** Use `search_game_tree` / `script_search` /
  `script_grep` to find what exists, and `script_read` before changing a script.
  Don't assume structure from this file or the vault — Studio is the source of truth.
- **Edit scripts with `multi_edit`** (Edit datamodel). Keep edits minimal and scoped.
- **Use `execute_luau` in the Edit datamodel for structural changes** (creating
  folders, RemoteEvents, GUIs, models, setting properties, creating a Script vs
  LocalScript vs ModuleScript of the right class). Edit-mode changes become real,
  saved instances the user can edit by hand — see "Build it in the place" below. Make these scripts idempotent — check whether an
  instance exists before creating it — and print what they changed.
- **Never** run destructive `execute_luau` (`:Destroy()`, `:ClearAllChildren()`, mass
  property changes) on things you didn't just create without telling the user first.
- **Assets:** prefer the user's Creator Inventory; check Creator Store assets for
  embedded scripts (backdoors are common) with `search_game_tree` after inserting,
  and tell the user what came in.
- **Changes are not saved to Roblox until the user saves/publishes in Studio.**
  Remind them after a meaningful batch of edits.

### Verifying changes

There is no file-based lint/typecheck. Instead, after changes:

1. `start_stop_play` to start a playtest, then `get_console_output` and check for
   errors and warnings from your scripts.
2. For gameplay changes, exercise them (`character_navigation`,
   `user_keyboard_input`/`user_mouse_input`, `execute_luau` in the Server/Client
   datamodel to inspect state, `screen_capture` for UI/visuals), or use
   `subagent` with type `playtest`.
3. `start_stop_play` to stop. Never leave Studio in play mode.
4. Report what you verified and what you couldn't — never claim a change works
   without having run it.

## Build it in the place, script the behavior

The user edits and visualizes the game by hand in Studio, so **GUIs and physical
game elements are built as real instances in the place first, and scripts only add
behavior to them.** Avoid GUIs, maps and models that only exist because a script
generates them at runtime.

**Order of work for a feature:**
1. **Build the visuals/physical parts** in the place: ScreenGuis in `StarterGui`,
   map pieces and props in `Workspace`, reusable models in `ReplicatedStorage.Assets`
   or `ServerStorage.Assets`. Use `execute_luau` in the **Edit** datamodel (or
   `insert_asset` / `generate_procedural_model`) so the result is saved in the place,
   then `screen_capture` to check it looks right.
2. **Let the user review/adjust** them by hand when the look matters.
3. **Then write the scripts** (server first, then client) that find those instances
   and wire up behavior.

**Rules:**
- **GUIs:** every screen, menu, HUD element, button and label exists in `StarterGui`
  with its real layout, sizes, colors and text. Client controllers get it with
  `Players.LocalPlayer.PlayerGui:WaitForChild("ShopGui")` and only connect events,
  set text/visibility and play tweens. Set `ResetOnSpawn = false` on ScreenGuis that
  controllers hold on to.
- **Repeated or dynamic items** (inventory slots, shop entries, leaderboard rows,
  damage numbers): build **one template** in Studio — an invisible `Template` child or
  a model in `Assets` — and `:Clone()` it. Never construct its look with `Instance.new`
  and property assignments in code.
- **Maps and models:** hand-placeable parts live in `Workspace` or `Assets`; runtime
  spawning clones those templates. Mark gameplay parts with **CollectionService tags**
  (e.g. `Hazard`, `BoardingPoint`) and per-instance tunables with **Attributes**
  (e.g. `Damage`, `Speed`) so the user can tweak them in the Properties panel. Code
  reads tags/attributes instead of hard-coding positions, sizes or values.
- **Keep it hand-editable:** clear `PascalCase` names (no default `Part`/`Frame`),
  grouped in Models/Folders, anchored unless meant to move, sensible `PrimaryPart`s/
  pivots, and UI using Scale-based sizes with `UIAspectRatioConstraint`/`UIListLayout`
  where appropriate.
- **Scripts must not overwrite hand-made design** — don't set colors, sizes, fonts,
  or positions in code that are already set on the instance, except for deliberate
  runtime state (health bar fill, hover/press effects, animations).
- Generating content in code is fine only when it's truly procedural or effect-like
  (projectiles, particles, procedural terrain). Say so and note the reason in the
  system's vault note.
- Record what each system expects to exist in the place (GUI names, tags,
  attributes, templates) in its `02 Systems/` note.

## Game architecture & Luau conventions

Target layout in the place (check what actually exists before relying on it):

```
ServerScriptService
└── Server (Script)            -- server bootstrap
    └── Services (Folder)      -- one ModuleScript per server service
StarterPlayer.StarterPlayerScripts
└── Client (LocalScript)       -- client bootstrap
    └── Controllers (Folder)   -- one ModuleScript per client controller
StarterGui                     -- all hand-built ScreenGuis (HUD, menus, shop, …)
Workspace
└── Map (Folder/Model)         -- hand-built level geometry and props
ReplicatedStorage
├── Shared (Folder)            -- ModuleScripts used by both sides
│   ├── Constants              -- game-wide tunables; no magic numbers inline
│   └── Types                  -- shared exported types
├── Assets (Folder)            -- templates clients also need (UI items, effects, models)
├── Packages (Folder)          -- third-party libraries (Promise, Signal, Trove, …)
└── Remotes (Folder)           -- RemoteEvents / RemoteFunctions
ServerStorage
└── Assets (Folder)            -- server-only templates (enemies, spawnable props)
```

- **Single-script architecture:** one Script on the server, one LocalScript on the
  client. Everything else is a ModuleScript. Services/Controllers return a table with
  optional `init()` and `start()`; the bootstraps call every `init()` first, then
  every `start()` in `task.spawn`. Don't yield in `init()`.
- Every script starts with `--!strict` unless there's a documented reason not to.
- Get services with `game:GetService("Name")` at the top of the file.
- Use `task.spawn`/`task.delay`/`task.wait`, never deprecated `spawn`/`delay`/`wait`.
- Type everything that crosses a module boundary; shared types go in `Shared.Types`.
- Naming: `PascalCase` for modules, instances, types; `camelCase` for locals and
  functions; `SCREAMING_SNAKE_CASE` for constants.
- Clean up connections and instances (Trove) to avoid leaks.
- Third-party libraries go in `ReplicatedStorage.Packages` as ModuleScripts. Prefer
  well-known libraries (Promise, Signal, Trove) over re-implementing them, and record
  the source and version in the vault (`05 Assets/Packages.md`).

### Networking & security (non-negotiable)

- **The server is authoritative.** Never trust the client for damage, currency,
  inventory, hit validation, cooldowns, or any game state.
- Every remote handler on the server validates argument types, ranges and rate before
  acting. Treat all client input as hostile.
- Avoid server→client `RemoteFunction` invokes (a client can yield the server forever).
- Data persistence goes through a single server module wrapping DataStores (session
  locking, retries, `BindToClose` saves). Never call DataStores ad hoc.

## Obsidian knowledge management

### Knowledge base

The Obsidian vault is the **`vault/` folder at the root of this repository**
(e.g. `C:\Users\<you>\...\storm-the-train\vault` on Windows). Open that folder
as a vault in Obsidian. Claude reads and writes it as plain Markdown with its
normal file tools — it does not need Obsidian running.

**Use this vault as persistent knowledge across development sessions.** Because the
code lives in Studio rather than git, the vault is also the **only versioned
description of the codebase**. Keeping it in the repo means every session — local
or cloud — sees the same notes.

```
vault/
├── Home.md                 # entry point / map of content — links to everything
├── Status.md               # project overview, current development status, known issues
├── 00 Inbox/               # unsorted / proposed ideas awaiting triage
├── 01 Design/              # GDD, feature specs, Art Direction
├── 02 Systems/             # one note per code system (Studio path, API, remotes)
├── 03 Decisions/           # architecture decision records (ADRs)
├── 04 Devlog/              # dated logs of meaningful sessions (YYYY-MM-DD.md)
├── 05 Assets/              # packages, asset tracking, References/ (reference images)
├── 06 Techniques/          # reusable how-tos, e.g. Blender modeling techniques
└── Templates/              # note templates (System, Feature, Decision, Devlog, Technique)
```

### At the start of each session

- Read `vault/Status.md` (project overview and current development status) and
  `vault/Home.md`.
- **Search for relevant notes before implementing a new feature**: `/graphify query`
  if the graph exists, otherwise grep the vault for the feature's names and keywords
  (and follow `[[wikilinks]]` from `Home.md`). Check `01 Design/` for the spec and
  `02 Systems/` for affected systems.
- **Consult `01 Design/Art Direction.md` and the reference images in
  `05 Assets/References/` before any 3D modeling**, mesh/material generation, or
  inserting assets — and check `06 Techniques/` for established Blender methods.
- **Load only the notes relevant to the task.** Don't read the whole vault.

### During development

- Document important architecture decisions as ADRs in `03 Decisions/`
  (`NNNN-short-title.md`, from `Templates/Decision.md`).
- Update feature specs in `01 Design/` when designs change.
- Keep `02 Systems/` notes in sync with Studio: when you add or materially change a
  service/controller, create or update its note from `Templates/System.md` (Studio
  path such as `ServerScriptService.Server.Services.TrainService`, purpose, public API,
  remotes, data, dependencies) and link it from `Home.md`.
- Record reusable Blender modeling techniques in `06 Techniques/`
  (from `Templates/Technique.md`).
- Track implementation progress and unresolved problems in `Status.md`.
- **Avoid duplicate notes**: search for an existing note on the topic first and
  extend it instead.

### At the end of each task

- Update affected notes with **confirmed** changes only (things verified in Studio).
- Summarize important decisions and their reasoning (in the ADR or feature note).
- Record unfinished tasks and known issues in `Status.md`, and note whether the place
  still needs saving/publishing in Studio.
- **Distinguish proposed ideas from implemented features** using the frontmatter
  `status` field: `proposed` → `planned` → `in-progress` → `implemented`
  (or `deprecated`). Unapproved ideas live in `00 Inbox/` with `status: proposed`.
  Source material that describes something outside this project (e.g. the original
  2016 game in `05 Assets/Original Game/`) uses `status: reference` and is never canon.
- For a meaningful session, add a short entry to `04 Devlog/YYYY-MM-DD.md`.

### Memory rules

- Do not document every conversation.
- Save information that will be useful in future sessions.
- Prefer updating existing notes rather than creating new ones.
- **Ask before overwriting major design decisions** (GDD, Art Direction, accepted
  ADRs). Supersede an ADR with a new one rather than rewriting it.
- **Never store credentials, API keys, cookies, or other secrets** in the vault.
- Use `[[wikilinks]]` and YAML frontmatter (`tags`, `status`) so Graphify and
  Obsidian's graph view can connect notes.
- Don't edit `vault/.obsidian/` beyond the shared config already committed.

## Graphify (knowledge graph)

[Graphify](https://github.com/safishamsi/graphify) builds a queryable knowledge
graph over the vault so Claude doesn't have to re-read every note.

Setup (once per machine; Python 3.10+):

```bash
pip install graphifyy && graphify install    # or pipx / uv tool install graphifyy
```

Usage inside Claude Code:

```
/graphify vault                 # build the graph → graphify-out/
/graphify vault --update        # re-extract only changed notes
/graphify query "how does boarding interact with the train's health?"
/graphify path "TrainService" "PlayerDataService"
/graphify explain "CombatService"
```

Output: `graphify-out/GRAPH_REPORT.md` (key nodes, surprising connections),
`graph.json` (persistent graph), `graph.html` (interactive), and `obsidian/` (graph
exported as an Obsidian vault). `cache/` is git-ignored.

- **At the start of a task that touches several systems, read
  `graphify-out/GRAPH_REPORT.md`** (if it exists) and use `/graphify query`/`path`/
  `explain` to find the relevant notes, then confirm against Studio.
- After significant vault changes, run `/graphify vault --update` and commit the
  updated `graph.json` and `GRAPH_REPORT.md`.
- Graphify only sees what's in the vault — it can't see scripts in Studio. Accurate
  `02 Systems/` notes are what make the code visible in the graph. Treat inferred
  edges as hints and verify them in Studio.

## Workflow expectations

- Small, focused commits to this repo (vault/docs) with descriptive messages.
- Don't commit `.rbxl`/`.rbxlx` place files unless the user asks; Roblox's own
  version history is the code backup.
- When unsure about a gameplay/design question, check the vault, then ask the user —
  don't invent design canon silently. Proposed design goes in `00 Inbox/`, flagged.
