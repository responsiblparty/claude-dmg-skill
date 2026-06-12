# /dmg — Claude Code skill for persistent memory + auto-sync

A Claude Code slash command that ends every session by committing dirty repos, refreshing documentation, and updating a persistent memory system — so the next session starts with full context.

`/dmg` = **d**ocumentation, **m**emories, **g**it.

---

## The problem

When you build things with Claude Code, context resets every session. You re-explain your project layout. You re-describe decisions you already made. Claude doesn't know what changed yesterday.

The other problem: after a productive session you have uncommitted work, stale docs, and no record of what you learned.

`/dmg` solves both. One command cleans up the session and primes the next one.

The highest-leverage thing it does: when Claude makes a mistake or you correct its approach, `/dmg` saves that as a **feedback memory**. Claude is far less likely to repeat the same mistake. Most context loss between sessions is silent — you don't notice until Claude repeats a bad call. Feedback memories are what break that cycle.

---

## What it does

**1. Git** — finds every repo touched during the session (including nested repos), commits anything dirty with a message explaining *why* the change was made, and appends the Claude Code co-author line.

**2. Docs** — updates whatever operational documentation went stale: README files, service tables, architecture docs. New projects and services get added to the right tables automatically.

**3. Memory** — updates a set of structured markdown files that persist across sessions. The next time you open Claude Code, it reads the index and knows your projects, your lessons learned, your preferences, and your infrastructure — without you re-explaining anything.

At the end it shows a clean `git status` across all repos as proof.

---

## Setup

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Install the skill

```bash
mkdir -p ~/.claude/skills/dmg
cp skills/dmg/SKILL.md ~/.claude/skills/dmg/SKILL.md
```

Claude Code loads any skill files found in `~/.claude/skills/` and makes them available as slash commands. After copying the file, type `/dmg` in any Claude Code session.

### 3. Set up the memory folder

```bash
# Pick a project name — usually matches your working directory
mkdir -p ~/.claude/projects/my-project/memory
cp memory/MEMORY.md ~/.claude/projects/my-project/memory/MEMORY.md

# Initialize as a git repo so the autocommit hook has somewhere to commit
cd ~/.claude/projects/my-project/memory
git init
git add MEMORY.md
git commit -m "init memory"
```

Start writing memory files as you go. Use the examples in `memory/examples/` as a starting point.

### 4. Wire up CLAUDE.md

Copy `CLAUDE.md` to your project root (or add its contents to an existing one). This tells Claude to read the memory index at session start.

```bash
cp CLAUDE.md ~/my-project/CLAUDE.md
```

### 5. Configure the skill for your setup

The skill needs to know your repo layout and doc conventions. The easiest way is to let Claude discover them:

```
/dmg --init
```

Claude will run a discovery script, show you what it found (repos, doc files, memory folders), ask four quick questions, and write a tailored `SKILL.md` for your setup. Takes about a minute.

**Or configure manually:** open `~/.claude/skills/dmg/SKILL.md` and edit the instructions to match your actual paths and doc file names. At minimum, tell it:
- Which directories are their own git repos vs. tracked by a parent
- Which documentation files to keep current
- Where your memory folder lives

### 6. (Optional) Autocommit hook

`/dmg` is a **manual trigger** — you invoke it and it commits. A session crash before you run `/dmg` means uncommitted memory updates are lost, the same as any workflow without autosave.

If you want continuous protection between invocations, add a hook that commits the memory folder automatically. This is the safety net layer; `/dmg` is the cleanup pass. You need both if you want crash safety.

The hook fires after every tool call (not on a timer), so the script debounces itself — it skips if the last commit was less than 5 minutes ago.

In your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/skills/dmg/autocommit.sh"
          }
        ]
      }
    ]
  }
}
```

`autocommit.sh` (create at `~/.claude/skills/dmg/autocommit.sh`):

```bash
#!/bin/bash
MEMORY_DIR="$HOME/.claude/projects/my-project/memory"
cd "$MEMORY_DIR" || exit 0
[[ -z $(git status --porcelain) ]] && exit 0
last=$(git log -1 --format=%ct 2>/dev/null || echo 0)
[[ $(( $(date +%s) - last )) -lt 300 ]] && exit 0
git add -A && git commit -m "auto: $(date '+%Y-%m-%d %H:%M:%S')" --quiet
```

### 7. (Optional) Host config versioning

`/dmg` can also snapshot host-level config files into a tracked `host-config/` directory in a repo you choose. Typical snapshots include `~/.claude/settings.json`, `crontab -l` output, and other tool configs that are rewritten by their owning applications. This is copy-based on purpose: many tools save config atomically by writing a replacement file and renaming it into place, which can silently flatten a symlink into a regular file outside your repo. The crontab snapshot is also a restore source with `crontab host-config/crontab.txt`.

This is opt-in. Enable it during `/dmg --init`, or manually edit `~/.claude/skills/dmg/SKILL.md` and fill in the host-config repo, copied config list, and optional `~/CLAUDE.md` symlink guard if you use that setup.

---

## Memory file format

Each memory file is a markdown file with YAML frontmatter:

```markdown
---
name: short-kebab-case-slug
description: "one line — used to decide relevance when scanning the index"
metadata:
  type: project   # project | feedback | user | reference
---

Content here. For feedback/lessons, use:

The rule or behavior.

**Why:** The reason — often a past incident or strong preference.
**How to apply:** When and where this kicks in.
```

The `MEMORY.md` index has one line per file:

```markdown
- [Title](filename.md) — one-line hook matching the description field
```

---

## Memory types

| Type | What goes here |
|------|---------------|
| `project` | Current state, file paths, open threads, architecture decisions |
| `feedback` | Lessons learned — what to do/avoid, and why |
| `user` | Your role, expertise, preferences, how you like to work |
| `reference` | Pointers to external resources: dashboards, docs, tickets |

---

## Usage

At the end of any session:

```
/dmg
```

Claude will scan every repo touched during the session, commit dirty work, update your docs, and sync the memory files. Takes 1–3 minutes depending on how much changed.

You can also trigger it mid-session if you want to checkpoint before switching tasks.

---

## Tips

- **Be specific in SKILL.md.** Generic instructions produce generic results. List your actual repo paths and doc file names.
- **Memory compounds over time.** The first session it's minimal. After a few weeks it knows your entire stack.
- **Feedback memories are the highest-value type.** When Claude makes a mistake or you correct its approach, save that as a feedback memory immediately. It is far less likely to make the same mistake again.
- **Keep the index short.** MEMORY.md is loaded every session — if it gets long, Claude spends tokens scanning it. One tight line per file.

---

## License

MIT
