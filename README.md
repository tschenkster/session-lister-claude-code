# sessions

A terminal session browser for [Claude Code](https://docs.claude.com/claude-code). Lists every session across every project — flat by recency or grouped by folder, your pick — with readable descriptions, and lets you jump back into any of them with one keystroke.

## Highlights

- **Every session in one picker.** Not scoped to the current folder like `claude -r`.
- **Pick the view that fits your head.** Three layouts — by project (default), flat by recency, or sessions grouped by project — toggled with Ctrl-T.
- **Type to filter, Enter to resume.** `fzf` fuzzy search; resume opens a fresh iTerm2 window so the picker stays up for the next jump.
- **Fast.** Pure local file scan. Cold ~0.4s, warm ~0.04s. No network, no daemon, no background indexer.
- **Drop-in install.** One Python file, stdlib only, no build step, no Node, no package manager juggling.
- **Read-only by default.** It looks at your sessions; it doesn't rewrite them. (One opt-in exception: `--name` to retroactively title a session.)

## The problem it solves

Claude Code stores each conversation as a JSONL file under `~/.claude/projects/<encoded-cwd>/<uuid>.jsonl`. The built-in `claude -r` picker is **cwd-scoped** — it only shows sessions whose working directory matches the one you launched from. A session started in `~/projects/my-app/frontend` is invisible when you open Claude at `~/projects/my-app` or anywhere else.

If you run many sessions across several project folders (a monorepo, a workspace of sub-projects, etc.), sessions disappear. You remember you were working on something yesterday, but you can't get back to it without guessing the right directory.

This tool fixes that. One command, one picker, all sessions.

## What you get

Three views, one picker:

```
# projects view (default) — one row per cwd you've ever opened Claude in
[side-projects/vacation-2026]    1w ago     3 sess  build a packing list
[coding-projects/landing-page]   1d ago     7 sess  wire up the formspree webhook
[coding-projects/my-app]         2h ago    24 sess  fix the auth redirect loop

# time view (Ctrl-T) — flat list of individual sessions by recency
[workspace-root]                 1d ago      draft blog post about async Python
[coding-projects/my-app]         5h ago      refactor the user model to split…
[coding-projects/my-app]         2h ago   🏷 fix the auth redirect loop

# project view (Ctrl-T again) — sessions clustered by project folder
[coding-projects/my-app]         5h ago      refactor the user model to split…
[coding-projects/my-app]         2h ago   🏷 fix the auth redirect loop
[side-projects/vacation-2026]    1w ago      build a packing list
```

- **Projects view (default)** — one row per unique cwd, complete history (no recency filter). Enter starts a **fresh** Claude Code session in that directory.
- **Time view (Ctrl-T)** — flat list of individual sessions sorted by last-active time, most recent at the bottom. Enter resumes the chosen session.
- **Project view (Ctrl-T again)** — sessions clustered by project folder, groups ordered by recent activity. Enter resumes the chosen session.
- Description for sessions = first user prompt. 🏷 marks sessions that also have an explicit custom title (visible in the preview pane).
- Row width adapts to the terminal — the wider your window, the more text you see per row.
- `fzf` picker, with preview pane showing session metadata + first 8 user prompts.
- Enter → opens a new **iTerm2** window, `cd`s into the recorded directory, and runs either `claude -r <uuid>` (session views) or `claude` (projects view). The picker stays running in the original terminal so you can launch another session immediately — press Esc to quit. (iTerm2 required — no Terminal.app fallback.)

### Picker keys

| Key | Action |
|---|---|
| Enter | Resume selected session, OR (in projects view) open a new session in that cwd |
| Space | Expand a `… N older session(s) …` group inline (session views only) |
| Ctrl-T | Cycle through projects → time → project views |
| Ctrl-R | Reset to the launch view |
| Esc | Quit the picker (after a launch the picker stays up — Esc is the way out) |

## Install

Requires Python 3 (stdlib only), `fzf`, and Claude Code.

```bash
# 1. fzf (if you don't have it)
brew install fzf       # macOS
# or your OS equivalent

# 2. clone + install
git clone https://github.com/tschenkster/session-lister-claude-code.git
cd session-lister-claude-code
./install.sh
```

`install.sh` symlinks `sessions` into `~/.local/bin/` and copies the `/sessions` slash command to `~/.claude/commands/`. Both are idempotent — re-run any time to update.

Make sure `~/.local/bin` is on your `PATH`.

## Usage

```bash
sessions                        # interactive fzf picker, projects view (default)
sessions --sort time            # picker, flat sessions by recency
sessions --sort project         # picker, sessions grouped by project folder
sessions --list                 # plain output, projects view (default)
sessions --list --sort time     # plain output, flat sessions by recency
sessions --list --sort project  # plain output, sessions grouped by project
sessions --today                # last 24h only (session views)
sessions --days 30              # last 30 days (session views)
sessions --project my-app       # filter by project substring (session views)
sessions --all                  # show everything, no filters (session views)
sessions --name <uuid> "title"  # retroactively name a session
sessions --resume <uuid>        # jump straight to a known UUID from anywhere
```

Inside an existing Claude Code session, the `/sessions` slash command prints the same grouped list (read-only — it doesn't launch anything, since resuming inside a session is awkward).

## Bloat control

These filters apply to the **session views** (`--sort time`, `--sort project`). The projects view bypasses all of them on purpose — it's the complete history of every cwd you've ever opened. Filters apply in this order:

1. **Empty sessions are hidden.** A session with no real user message (just `/clear` or aborted startup) is treated as noise. `--include-empty` overrides.
2. **56-day recency window (~8 weeks).** Older sessions are almost always "already finished or forgotten." `--days N` or `--all` overrides.
3. **Per-project cap: 10 most-recent per group.** Stops a chatty project from drowning the list. A footer reveals how many were hidden and how to see them: `--project <slug>` disables the cap for that one group.
4. **Global ceiling: 300 rows.** If filters still return more, truncate with a footer. `--all` disables.

`fzf`'s fuzzy search gives you back anything you can name — type "auth" or "olli" to find a session regardless of age, as long as it survived the filters above. For older matches, use `--days 90` or `--all`.

Typical default view: ~150–200 sessions across 8 weeks. fzf scrolls.

## How it works

Pure Python 3 stdlib. No daemon, no background indexer.

- Walks `~/.claude/projects/*/*.jsonl` and extracts per-session metadata:
  - `cwd` and `gitBranch` (from the first `system` / `user` record)
  - `customTitle` (latest wins — matches Claude Code's own behavior)
  - First non-meta user prompt (skips command wrappers, local-command-stdout, and `<system-reminder>` blocks)
  - File mtime (last active) and size
- Derives a project label by stripping the workspace prefix from `cwd`.
- Caches the index at `~/.cache/sessions/index.json` with a 5-minute TTL. Auto-invalidates when any JSONL is newer than the cache.
- Resume = open a new iTerm2 window via `osascript` and run `cd <cwd> && claude -r <uuid>` in it. From the projects view, the same path runs `cd <cwd> && claude` to start a fresh session in that directory.

The tool is **read-only** with one exception: `--name <uuid> "<title>"` appends a `{"type":"custom-title", ...}` record to the session's JSONL — the same format Claude Code writes when you use `claude -n` or `/name`.

### Why Python (and not Go, Rust, Bash, or Node)?

For a small personal utility that walks files and shells out to `fzf` and `claude`, Python is the path of least resistance:

- **Already installed.** Python 3 ships with macOS. Nothing to download, no toolchain, no version manager.
- **No build step.** The file `sessions` *is* the program — edit it, save, run. Go and Rust would give you a snappier binary at the cost of a compile pipeline; for ~0.4s cold scans, that trade isn't worth it.
- **Stdlib covers the job.** Walking directories, parsing JSONL, caching to disk, spawning subprocesses — all in the standard library. No `pip install`, no virtualenv, no dependency drift.
- **Bash would have been miserable.** JSONL parsing and the token-counting preview logic are clean in Python and painful in pure shell.
- **Node would push install friction onto users.** Python doesn't — it's already there.

The only external runtime requirement is `fzf`, which does the heavy lifting of the picker UI better than anything you'd write yourself.

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
