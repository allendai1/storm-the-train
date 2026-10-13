#!/usr/bin/env bash
# Quality gate: sourcemap -> format check -> lint -> type check.
# Run from the repo root after `rokit install` and `wally install`.
set -euo pipefail
cd "$(dirname "$0")/.."

DEFS="globalTypes.d.luau"
DEFS_URL="https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau"

echo "==> rojo sourcemap"
rojo sourcemap default.project.json -o sourcemap.json

if [ -d Packages ]; then
	echo "==> wally-package-types"
	wally-package-types --sourcemap sourcemap.json Packages/
fi

echo "==> stylua --check"
stylua --check src

echo "==> selene"
selene src

if [ ! -f "$DEFS" ]; then
	echo "==> downloading Roblox type definitions"
	curl -fsSL "$DEFS_URL" -o "$DEFS"
fi

echo "==> luau-lsp analyze"
luau-lsp analyze \
	--platform=roblox \
	--defs="$DEFS" \
	--sourcemap=sourcemap.json \
	--ignore="Packages/**" \
	src

echo "All checks passed."
