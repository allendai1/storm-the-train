# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**Storm the Train** is a Roblox experience written in **Luau**. Development is
**Studio-first**: the game, including all scripts, lives in the Roblox place and is
edited directly in Roblox Studio. Claude works on the place through the
**Roblox Studio MCP server** (built into Studio). There is no Rojo and no file sync.

This repository holds the project's knowledge, not its code:

- **Obsidian vault** (`vault/`) — design docs, system notes, decisions, devlog.
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
  folders, RemoteEvents, setting properties, creating a Script vs LocalScript vs
  ModuleScript of the right class). Make these scripts idempotent — check whether an
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

## Game architecture & Luau conventions

Target layout in the place (check what actually exists before relying on it):

```
ServerScriptService
└── Server (Script)            -- server bootstrap
    └── Services (Folder)      -- one ModuleScript per server service
StarterPlayer.StarterPlayerScripts
└── Client (LocalScript)       -- client bootstrap
    └── Controllers (Folder)   -- one ModuleScript per client controller
ReplicatedStorage
├── Shared (Folder)            -- ModuleScripts used by both sides
│   ├── Constants              -- tunables; no magic numbers inline
│   └── Types                  -- shared exported types
├── Packages (Folder)          -- third-party libraries (Promise, Signal, Trove, …)
└── Remotes (Folder)           -- RemoteEvents / RemoteFunctions
ServerStorage                  -- server-only assets and modules
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

## Obsidian vault (`vault/`)

The vault is the project's design memory and — because code lives in Studio, not in
git — the **only versioned description of the codebase**. Open `vault/` as a vault in
Obsidian. Claude reads and writes it as plain Markdown.

```
vault/
├── Home.md                 # entry point / map of content — start here
├── 00 Inbox/               # unsorted ideas and notes
├── 01 Design/              # game design doc, core loop, mechanics, economy
├── 02 Systems/             # one note per code system (Studio path, API, remotes)
├── 03 Decisions/           # architecture decision records (ADRs)
├── 04 Devlog/              # dated session logs (YYYY-MM-DD.md)
├── 05 Assets/              # assets, packages and their sources
└── Templates/              # note templates (System, Decision, Devlog)
```

1. **Read before designing.** Before implementing or changing a feature, read
   `vault/Home.md` and the relevant `01 Design/` and `02 Systems/` notes.
2. **Keep systems notes in sync with Studio.** When you add or materially change a
   service/controller, create or update its note in `02 Systems/` from
   `Templates/System.md`: Studio path (e.g. `ServerScriptService.Server.Services.TrainService`),
   purpose, public API, remotes, data, dependencies. Link it from `Home.md`.
3. **Record decisions.** Non-trivial architecture or design choices get an ADR in
   `03 Decisions/` (`NNNN-short-title.md`, from `Templates/Decision.md`).
4. **Log sessions.** At the end of a meaningful session, append to today's
   `04 Devlog/YYYY-MM-DD.md`: what changed in Studio, what's next, open questions,
   and whether the place still needs saving/publishing.
5. Use `[[wikilinks]]` between notes and YAML frontmatter (`tags`, `status`) so
   Graphify and Obsidian's graph view can connect them.
6. Don't edit `vault/.obsidian/` beyond the shared config already committed.

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
