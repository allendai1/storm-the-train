# Storm the Train

A Roblox experience built with a file-based Luau workflow.

- **Code:** `src/`, synced into Roblox Studio with [Rojo](https://rojo.space)
- **Design docs:** `vault/` — open it as an [Obsidian](https://obsidian.md) vault
- **Knowledge graph:** [Graphify](https://github.com/safishamsi/graphify) output in `graphify-out/`
- **AI guidance:** see [`CLAUDE.md`](CLAUDE.md)

## Getting started

1. Install [Rokit](https://github.com/rojo-rbx/rokit), then from the repo root:
   ```bash
   rokit install      # rojo, wally, selene, stylua, luau-lsp
   wally install      # Luau packages → Packages/
   ```
2. Install the Rojo plugin in Studio (`rojo plugin install`), then:
   ```bash
   rojo serve
   ```
   and click **Connect** in the Rojo plugin.
3. (Optional) VS Code: install the recommended extensions in `.vscode/extensions.json`.
4. (Optional) Graphify, for Claude Code: `pip install graphifyy && graphify install`, then `/graphify .`

## Checks

```bash
./scripts/check.sh   # sourcemap, stylua, selene, luau-lsp
```
