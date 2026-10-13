# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**Storm the Train** is a Roblox experience written in **Luau** and developed with a
file-based workflow: source lives in this repo and is synced into Roblox Studio with
**Rojo**. Design knowledge lives in an **Obsidian vault** (`vault/`), and **Graphify**
builds a queryable knowledge graph over the vault and code.

Roblox Studio is not available in cloud/CI sessions. Anything that needs Studio
(play-testing, publishing, editing places) must be done by the user locally — say so
rather than pretending to verify it.

## Repository layout

```
.
├── CLAUDE.md               # this file
├── default.project.json    # Rojo project: maps src/ into the Roblox DataModel
├── rokit.toml              # pinned toolchain (rojo, wally, selene, stylua, luau-lsp)
├── wally.toml              # Luau package dependencies
├── selene.toml             # linter config (std = roblox)
├── stylua.toml             # formatter config
├── .luaurc                 # Luau language mode (strict)
├── scripts/check.sh        # full quality gate: sourcemap → stylua → selene → luau-lsp
├── src/
│   ├── server/             # → ServerScriptService.Server   (init.server.luau bootstraps)
│   │   └── Services/       # one ModuleScript per server service
│   ├── client/             # → StarterPlayerScripts.Client  (init.client.luau bootstraps)
│   │   └── Controllers/    # one ModuleScript per client controller
│   └── shared/             # → ReplicatedStorage.Shared     (code used by both sides)
├── vault/                  # Obsidian vault — design docs, decisions, devlog
└── graphify-out/           # generated knowledge graph (see "Graphify" below)
```

Generated, git-ignored: `Packages/`, `DevPackages/`, `sourcemap.json`,
`globalTypes.d.luau`, `graphify-out/cache/`.

## Toolchain

All CLI tools are pinned in `rokit.toml` and installed with [Rokit](https://github.com/rojo-rbx/rokit):

| Tool | Purpose |
|------|---------|
| `rojo` | Sync `src/` into Studio, build `.rbxl` files, generate `sourcemap.json` |
| `wally` | Package manager for Luau dependencies (`wally.toml`) |
| `wally-package-types` | Re-exports types from Wally packages so luau-lsp can see them |
| `selene` | Linter (`selene.toml`, Roblox std) |
| `stylua` | Formatter (`stylua.toml`) |
| `luau-lsp` | Type checker / language server (`luau-lsp analyze`) |

### Common commands

```bash
rokit install                                   # install pinned tools
wally install                                   # install packages into Packages/
rojo sourcemap default.project.json -o sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/

rojo serve                                      # live-sync to Studio (Rojo plugin)
rojo build -o build/storm-the-train.rbxl        # build a place file

stylua src                                      # format
selene src                                      # lint
./scripts/check.sh                              # everything CI would check
```

**Before finishing any code change, run `./scripts/check.sh`** (or the individual
steps above if a tool is missing). If tools can't be installed in the current
environment, say which checks were skipped — never claim they passed.

## Luau conventions

- Files use the `.luau` extension. Every file starts with `--!strict` unless there is
  a concrete reason it can't (document the reason in a comment).
- Rojo naming: `init.server.luau` / `init.client.luau` make the *folder* a Script /
  LocalScript; `Foo.luau` is a ModuleScript; `Foo.server.luau` / `Foo.client.luau`
  are Scripts / LocalScripts.
- Exactly one Script on the server (`src/server/init.server.luau`) and one LocalScript
  on the client (`src/client/init.client.luau`). Everything else is a ModuleScript
  loaded by those bootstraps (single-script architecture).
- Services (server) and Controllers (client) are ModuleScripts that return a table
  with optional `init()` and `start()` functions. Bootstraps call every `init()`
  first, then every `start()`. Don't yield in `init()`.
- Get services with `game:GetService("Name")` at the top of the file; never index
  `game.Name` directly.
- Use `task.spawn`/`task.delay`/`task.wait`, never the deprecated `spawn`/`delay`/`wait`.
- Type everything that crosses a module boundary. Export shared types from
  `src/shared/Types.luau`.
- Constants and tunables go in `src/shared/Constants.luau`, not inline magic numbers.
- Naming: `PascalCase` for modules, types and services; `camelCase` for locals and
  functions; `SCREAMING_SNAKE_CASE` for constants.
- Clean up connections and instances (use `Trove` from Packages) to avoid leaks.

### Networking & security (non-negotiable)

- **The server is authoritative.** Never trust the client for damage, currency,
  inventory, positions used for hit validation, cooldowns, or any game state.
- Every `RemoteEvent`/`RemoteFunction` handler on the server must validate argument
  types, ranges and rate before acting. Treat all client input as hostile.
- Avoid `RemoteFunction` server→client invokes (a client can yield the server forever).
- Data persistence goes through a single server module wrapping DataStores
  (session locking, retries, `BindToClose` saves). Never call DataStores ad hoc.

## Obsidian vault (`vault/`)

The vault is the project's design memory. Open the `vault/` folder as a vault in
Obsidian. Claude reads and writes it as plain Markdown.

```
vault/
├── Home.md                 # entry point / map of content — start here
├── 00 Inbox/               # unsorted ideas and notes
├── 01 Design/              # game design doc, core loop, mechanics, economy
├── 02 Systems/             # one note per code system (maps to src/ modules)
├── 03 Decisions/           # architecture decision records (ADRs)
├── 04 Devlog/              # dated session logs (YYYY-MM-DD.md)
├── 05 Assets/              # art/audio/asset tracking and references
└── Templates/              # note templates (System, Decision, Devlog)
```

Rules for working with the vault:

1. **Read before designing.** Before implementing or changing a feature, read
   `vault/Home.md` and the relevant `01 Design/` and `02 Systems/` notes.
2. **Keep systems notes in sync with code.** When you add or materially change a
   service/controller, create or update its note in `02 Systems/` using
   `Templates/System.md` (purpose, file path, public API, remotes, data, dependencies).
3. **Record decisions.** Non-trivial architecture or design choices get an ADR in
   `03 Decisions/` (`NNNN-short-title.md`, from `Templates/Decision.md`).
4. **Log sessions.** At the end of a meaningful work session, append to today's
   `04 Devlog/YYYY-MM-DD.md` (what changed, what's next, open questions).
5. Use Obsidian `[[wikilinks]]` between notes and YAML frontmatter (`tags`,
   `status`) so Graphify and Obsidian's graph view can connect them.
6. Don't edit `vault/.obsidian/` except for the shared config already committed;
   personal workspace files are git-ignored.

## Graphify (knowledge graph)

[Graphify](https://github.com/safishamsi/graphify) turns the vault and code into a
knowledge graph Claude can query instead of re-reading every file.

Setup (once per machine; requires Python 3.10+):

```bash
pip install graphifyy && graphify install    # or: pipx install graphifyy / uv tool install graphifyy
```

Usage inside Claude Code:

```
/graphify .                 # build the graph for the repo → graphify-out/
/graphify . --update        # re-extract only changed files (use after edits)
/graphify query "how does the boarding system talk to the train controller?"
/graphify path "TrainService" "PlayerDataService"
/graphify explain "CombatService"
```

Output in `graphify-out/`: `GRAPH_REPORT.md` (key nodes, surprising connections),
`graph.json` (persistent graph), `graph.html` (interactive view), and `obsidian/`
(the graph exported as an Obsidian vault). `cache/` is git-ignored.

How Claude should use it:

- **At the start of a task that touches several systems, read
  `graphify-out/GRAPH_REPORT.md`** (if it exists) and prefer `/graphify query` /
  `path` / `explain` over broad file sweeps to find relevant code and notes.
- After significant changes to the vault or code, run `/graphify . --update` and
  commit the updated `graph.json` and `GRAPH_REPORT.md`.
- Note: Graphify's tree-sitter AST pass doesn't list Luau among its supported
  languages, so its view of `src/` is weaker than for docs. Keep `02 Systems/` notes
  accurate — they are what makes the code legible in the graph. Verify anything the
  graph *infers* against the actual source before relying on it.
- Optional: `graphify hook install` adds a post-commit hook that rebuilds the graph
  automatically.

## Workflow expectations

- Small, focused commits with descriptive messages.
- Prefer battle-tested Wally packages (already in `wally.toml`: Promise, Signal,
  Trove) over re-implementing them. Add new packages to `wally.toml`, then run
  `wally install` and regenerate package types.
- Don't commit `.rbxl`/`.rbxlx` place files or generated folders.
- When unsure about a gameplay/design question, check the vault first, then ask the
  user — don't invent design canon silently. If you do propose design, put it in
  `00 Inbox/` and flag it.
