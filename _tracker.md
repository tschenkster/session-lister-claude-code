# session-lister-claude-code — Tracker

## Done
- [x] 2026-04-29: Rename project to session-lister-claude-code; resume in new iTerm2 window
- [x] 2026-04-24: Initial release — `sessions` CLI + `/sessions` slash command, pushed to GitHub
- [x] 2026-04-24: Add install.sh, MIT LICENSE, README with bloat-control docs

## Next
- [ ] Add `sessions --prune` to archive session dirs whose cwd no longer exists
- [ ] Add a small `sessions --stats` summary (total sessions, per-project counts, disk footprint)

## Ideas
- [ ] Homebrew tap formula once the tool stabilises
- [ ] `sessions --grep <pattern>` to search inside session prompts (currently only works within fzf filter)
