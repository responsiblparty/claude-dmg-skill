---
name: dmg
description: Sync documentation, memories, and git for everything touched this session — commit all dirty repos, refresh project docs, update memory files + MEMORY.md index, then show git-clean proof.
---

Bring documentation, memories, and git up to date for all work done this session. Do not ask questions — verify each item and fix what's stale:

1. **Git** — for every directory touched this session, find its repo (`git status`). Watch for nested repos: the root server/monorepo may have individual project dirs that are their own git repos — a file can be ignored in the parent and tracked in the child, or vice versa. Commit anything dirty with a descriptive message explaining *why* the change was made, not just what changed. End commit messages with the Claude Code co-author line:
   ```
   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   ```

2. **Documentation** — update what the changes made stale:
   - `README.md` for any touched project
   - Any operational docs you maintain (service tables, architecture docs, runbooks) — whichever apply to what was touched
   - New projects or services must be added to the relevant doc tables

3. **Memories** — update `~/.claude/projects/<your-project>/memory/`:
   - The relevant memory file for what changed (update in place; create a new file only if nothing covers it)
   - The matching one-line entry in `MEMORY.md` index — keep it current with the file's actual content
   - Capture lessons learned (the *why* + *how to apply*), not restatements of what the repo already records

4. **Verify and report** — show final `git status` proof that all touched repos are clean. Report tersely: what was updated, what was already current. If something was already done earlier this session, say so instead of redoing it.
