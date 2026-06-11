---
name: dmg
description: Sync documentation, memories, and git for everything touched this session — commit all dirty repos, refresh project docs, update memory files + MEMORY.md index, then show git-clean proof. Use /dmg --init on first run to generate a tailored SKILL.md for your setup.
---

## If invoked with `--init`

Run the initialization flow. This replaces the current SKILL.md with a version tailored to the user's actual setup.

1. **Run the discovery script** and parse its output:
   ```
   bash ~/.claude/skills/dmg/discover.sh
   ```

2. **Present findings** grouped clearly:
   - Standalone repos (no parent repo) — list path and doc files found
   - Nested repos (parent also a git repo) — list with parent noted
   - Memory folders found (MEMORY.md paths)
   - Whether a SKILL.md already exists

3. **Ask the user four things** (present as a numbered list, wait for a single reply):
   - "Which repos should `/dmg` commit?" — default: all found; user can exclude or add paths
   - "For which repos should `/dmg` refresh docs?" — default: ones with doc files; list them
   - "Where is your memory folder?" — default: first MEMORY.md found, or ask if none
   - "Anything else to include?" — catch-all for custom hooks, extra paths, or conventions

4. **Write a new SKILL.md** to `~/.claude/skills/dmg/SKILL.md` based on the answers. Start from the full current contents of this file — keep the `## If invoked with --init` section verbatim at the top (re-init must remain available after first use), then replace only the "Normal invocation" section's generic placeholders with the user's actual paths and doc file names. Be specific — list each repo by absolute path, each doc file by name. Confirm the path before writing.

5. **Confirm completion**: show the written SKILL.md and say "Run `/dmg` to test it."

---

## Normal invocation (no args)

Bring documentation, memories, and git up to date for all work done this session. Do not ask questions — verify each item and fix what's stale:

1. **Git** — for every directory touched this session, find its repo (`git status`). Watch for nested repos: the root server/monorepo may have individual project dirs that are their own git repos — a file can be ignored in the parent and tracked in the child, or vice versa. Commit anything dirty with a descriptive message explaining *why* the change was made, not just what changed. End commit messages with the Claude Code co-author line:
   ```
   Co-Authored-By: Claude Code <noreply@anthropic.com>
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
