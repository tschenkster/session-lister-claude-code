#!/usr/bin/env bash
# Install the `sessions` CLI and the `/sessions` slash command.
# Idempotent — re-run to update.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CLAUDE_CMD_DIR="${HOME}/.claude/commands"

mkdir -p "${BIN_DIR}" "${CLAUDE_CMD_DIR}"

# 1. CLI: symlink so updates in the repo are picked up automatically
ln -sf "${REPO_DIR}/sessions" "${BIN_DIR}/sessions"
chmod +x "${REPO_DIR}/sessions"
echo "→ installed ${BIN_DIR}/sessions → ${REPO_DIR}/sessions"

# 2. Slash command: copy (Claude Code reads this from ~/.claude/commands/)
cp "${REPO_DIR}/commands/sessions.md" "${CLAUDE_CMD_DIR}/sessions.md"
echo "→ installed ${CLAUDE_CMD_DIR}/sessions.md"

# 3. fzf check
if ! command -v fzf >/dev/null 2>&1; then
  echo
  echo "⚠ fzf not found on PATH. Install it for the picker UI:"
  echo "    brew install fzf        # macOS"
  echo "    apt install fzf         # Debian/Ubuntu"
  echo "    pacman -S fzf           # Arch"
fi

# 4. PATH check
case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *)
    echo
    echo "⚠ ${BIN_DIR} is not on your PATH. Add this to ~/.zshrc or ~/.bashrc:"
    echo "    export PATH=\"\${HOME}/.local/bin:\${PATH}\""
    ;;
esac

echo
echo "Done. Try:  sessions --list"
