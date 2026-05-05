# session-lister-claude-code

Public utility for browsing and resuming Claude Code sessions across all project folders. Solves the cwd-scoping limitation of the built-in `claude -r` picker.

GitHub: https://github.com/tschenkster/session-lister-claude-code (MIT)

## Structure

- `sessions` — Python 3 CLI (single file, stdlib-only). Uses `fzf` for the picker UI.
- `commands/sessions.md` — slash command shipped for installation to `~/.claude/commands/`.
- `install.sh` — idempotent installer: symlinks `sessions` into `~/.local/bin/`, copies the slash command.
- `README.md` — user-facing docs (problem / install / usage / bloat controls / architecture / limitations).

## Constraints

- **Python 3 stdlib only.** Do not add third-party dependencies. `fzf` is the only external runtime requirement.
- **Single-file CLI.** No package structure. Keep everything in `sessions`.
- **Read-only by default.** The one exception is `sessions --name <uuid> "<title>"` which appends a `custom-title` record to the session's JSONL.
- **macOS is primary.** Linux paths should work; Windows is not supported.
- **License is MIT.** Any new files must be MIT-compatible.

## Testing

No formal test suite. Smoke checks on a machine with a populated `~/.claude/projects/`:

- `sessions --list` → default-filtered output (non-empty, 14-day, per-group cap 10, global 60).
- `sessions --all --list | wc -l` should match `find ~/.claude/projects -maxdepth 2 -name '*.jsonl' | wc -l`.
- `sessions --project <slug>` bypasses the per-group cap.
- `sessions --name <uuid> "<title>"` is readable back via `sessions --list --project <slug>`.
- Cache: cold run ~0.4s, warm run ~0.04s.


## Claude Memory Sync

Claude Code's hidden internal memory (`~/.claude/projects/`) is automatically synced to the `35-knowledge/claude-memory/` directory at the root of the main Claude Workspace.

**ATTENTION ALL AI AGENTS:**
- **Google Antigravity, OpenAI Codex, & Other Agents**: You MUST read `/Users/thomas/Library/CloudStorage/GoogleDrive-thomas@cfo-team.de/My Drive/Claude Workspace /35-knowledge/claude-memory/workspace_MEMORY.md` when starting tasks to gather context on established rules.
- **Claude Code**: You MUST COMPLETELY IGNORE the `35-knowledge/claude-memory/` directory. It is a mirror of your own internal memory. Rely exclusively on your native `~/.claude/projects/` memory to prevent infinite loops and memory bloat.
