# Storm the Train

A Roblox experience built in Roblox Studio, with Claude Code connected through
Studio's built-in MCP server.

- **Game & code:** live in the Roblox place (Studio is the source of truth)
- **Design docs:** `vault/` — open it as an [Obsidian](https://obsidian.md) vault
- **Knowledge graph:** [Graphify](https://github.com/safishamsi/graphify) output in `graphify-out/`
- **AI guidance:** see [`CLAUDE.md`](CLAUDE.md)

## Getting started

1. Update Roblox Studio, then enable the MCP server:
   **Assistant → … → Manage MCP Servers → Enable Studio as MCP server**.
2. Connect Claude Code — turn on **Claude Code** under **Quick connect** in that panel, or:
   ```bash
   # macOS
   claude mcp add --transport stdio Roblox_Studio -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP
   # Windows
   claude mcp add --transport stdio Roblox_Studio -- cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat
   ```
3. Restart Claude Code, open the place in Studio, and check for the green connected indicator.
4. (Optional) Graphify: `pip install graphifyy && graphify install`, then `/graphify vault` in Claude Code.

See the [Studio MCP docs](https://create.roblox.com/docs/studio/mcp) for details.
