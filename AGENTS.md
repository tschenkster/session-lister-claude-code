# claude-code-session-lister

Public utility for browsing and resuming Claude Code sessions across all project folders. Solves the cwd-scoping limitation of the built-in `claude -r` picker.

GitHub: https://github.com/tschenkster/claude-code-session-lister (MIT)

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
