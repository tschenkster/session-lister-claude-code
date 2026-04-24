---
description: List Claude Code sessions across all workspace projects
argument-hint: [today|all|project <slug>|days N]
allowed-tools: Bash(sessions:*)
---

Run `sessions --list` with the right flags based on `$ARGUMENTS`, then show the grouped output verbatim.

Argument mapping:
- empty → `sessions --list`
- `today` → `sessions --list --today`
- `all` → `sessions --list --all`
- `project <slug>` → `sessions --list --project <slug>`
- `days <N>` → `sessions --list --days <N>`
- otherwise pass through as-is: `sessions --list $ARGUMENTS`

Then append a one-line reminder:
> To resume: open a fresh terminal and run `sessions` (or `sessions --resume <uuid>`). Running `claude -r` inside this session won't jump you into the other one.
