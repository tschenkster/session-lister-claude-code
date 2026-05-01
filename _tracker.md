# session-lister-claude-code — Tracker

## Done
- [x] 2026-05-01: Picker stays open after launching iTerm; Esc quits
- [x] 2026-05-01: Show context-window tokens in preview instead of bytes on disk
- [x] 2026-05-01: Add projects view (one row per cwd, complete history); Ctrl-T cycles 3 views; projects becomes default; Enter opens fresh session
- [x] 2026-04-29: Add time/project view toggle (Ctrl-T), default time view
- [x] 2026-04-29: Adapt row widths to terminal size; let fzf truncate per pane
- [x] 2026-04-29: Strip [Image #N] placeholders; prefer first prompt over stale custom_title
- [x] 2026-04-29: Add Ctrl-R reset, Space-to-expand overflow groups
- [x] 2026-04-29: Reduce preview pane to 30% so list gets more space
- [x] 2026-04-29: Auto-rewrite cwd in JSONLs during folder rename; resume opens iTerm2
- [x] 2026-04-29: Rename project to session-lister-claude-code
- [x] 2026-04-24: Initial release — `sessions` CLI + `/sessions` slash command, pushed to GitHub
- [x] 2026-04-24: Add install.sh, MIT LICENSE, README with bloat-control docs

## Next
- [ ] Add `sessions --prune` to archive session dirs whose cwd no longer exists
- [ ] Add a small `sessions --stats` summary (total sessions, per-project counts, disk footprint)

## Ideas
- [ ] Homebrew tap formula once the tool stabilises
- [ ] `sessions --grep <pattern>` to search inside session prompts (currently only works within fzf filter)
