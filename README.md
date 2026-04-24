# sessions

A terminal session browser for [Claude Code](https://docs.claude.com/claude-code). Lists every session across every project, grouped by folder, with readable descriptions, and lets you jump back into any of them with one keystroke.

## The problem it solves

Claude Code stores each conversation as a JSONL file under `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl`. The built-in `claude -r` picker is **cwd-scoped** — it only shows sessions whose working directory matches the one you launched from. A session started in `~/projects/my-app/frontend` is invisible when you open Claude at `~/projects/my-app` or anywhere else.

If you run many sessions across several project folders (a monorepo, a workspace of sub-projects, etc.), sessions disappear. You remember you were working on something yesterday, but you can't get back to it without guessing the right directory.

This tool fixes that. One command, one picker, all sessions.

## What you get

```
[coding-projects/my-app]         2h ago   🏷 fix-auth-redirect-loop
[coding-projects/my-app]         5h ago      refactor the user model to split…
[coding-projects/landing-page]   1d ago   🏷 wire-up-formspree-webhook
[workspace-root]                 1d ago      draft blog post about async Python
[side-projects/vacation-2026]    1w ago      build a packing list
    … 14 older session(s) in workspace-root — use --project workspace-root --all
```

- Grouped by project folder (derived from each session's recorded `cwd`).
- Title 🏷 shown when the session was explicitly named (via `claude -n` or retroactively).
- Untitled sessions use the first 80 chars of the opening prompt.
- `fzf` picker on top. Preview pane shows session metadata + first 8 user prompts.
- Enter → `cd` into the right directory and `claude -r <uuid>`.

## Install

Requires Python 3 (stdlib only), `fzf`, and Claude Code.

```bash
# 1. fzf (if you don't have it)
brew install fzf       # macOS
# or your OS equivalent

# 2. clone + install
git clone https://github.com/tschenkster/claude-code-session-lister.git
cd claude-code-session-lister
./install.sh
```

`install.sh` symlinks `sessions` into `~/.local/bin/` and copies the `/sessions` slash command to `~/.claude/commands/`. Both are idempotent — re-run any time to update.

Make sure `~/.local/bin` is on your `PATH`.

## Usage

```bash
sessions                        # interactive fzf picker (default)
sessions --list                 # plain grouped output
sessions --today                # last 24h only
sessions --days 30              # last 30 days
sessions --project my-app       # filter by project substring
sessions --all                  # show everything, no filters
sessions --name <uuid> "title"  # retroactively name a session
sessions --resume <uuid>        # jump straight to a known UUID from anywhere
```

Inside an existing Claude Code session, the `/sessions` slash command prints the same grouped list (read-only — it doesn't launch anything, since resuming inside a session is awkward).

## Bloat control

The default view is deliberately narrow. Filters apply in this order:

1. **Empty sessions are hidden.** A session with no real user message (just `/clear` or aborted startup) is treated as noise. `--include-empty` overrides.
2. **14-day recency window.** Older sessions are almost always "already finished or forgotten." `--days N` or `--all` overrides.
3. **Per-project cap: 10 most-recent per group.** Stops a chatty project from drowning the list. A footer reveals how many were hidden and how to see them: `--project <slug>` disables the cap for that one group.
4. **Global ceiling: 60 rows.** If filters still return more, truncate with a footer. `--all` disables.

`fzf`'s fuzzy search gives you back anything you can name — type "auth" or "olli" to find a session regardless of age, as long as it survived the filters above. For older matches, use `--days 90` or `--all`.

Typical default view: 30–50 sessions. One comfortable fzf screen.

## How it works

Pure Python 3 stdlib. No daemon, no background indexer.

- Walks `~/.claude/projects/*/*.jsonl` and extracts per-session metadata:
  - `cwd` and `gitBranch` (from the first `system` / `user` record)
  - `customTitle` (latest wins — matches Claude Code's own behavior)
  - First non-meta user prompt (skips command wrappers, local-command-stdout, and `<system-reminder>` blocks)
  - File mtime (last active) and size
- Derives a project label by stripping the workspace prefix from `cwd`.
- Caches the index at `~/.cache/sessions/index.json` with a 5-minute TTL. Auto-invalidates when any JSONL is newer than the cache.
- Resume = `cd` into the recorded `cwd` and `exec claude -r <uuid>`.

The tool is **read-only** with one exception: `--name <uuid> "<title>"` appends a `{"type":"custom-title", ...}` record to the session's JSONL — the same format Claude Code writes when you use `claude -n` or `/name`.

## Configuration

No config file. Everything is flags. A few things you might want to tweak in the script:

- `CACHE_TTL` (default 300 seconds)
- `WORKSPACE_PREFIX` — the path under which sessions get short project labels. Sessions outside this prefix are shown as `external/<basename>`. Edit near the top of the script if your setup differs.

## Limitations

- **Encoded directory is lossy.** Claude Code replaces non-alphanumeric characters with dashes when naming the project directory, so you can't recover the original cwd from the directory name alone. The tool reads `cwd` from inside the JSONL instead.
- **No auto-prune.** `~/.claude/projects/` accumulates directories for deleted folders. Add one if you need it; trivial to script.
- **macOS / Linux assumed.** Windows paths are not handled.

## License

MIT. See `LICENSE`.
