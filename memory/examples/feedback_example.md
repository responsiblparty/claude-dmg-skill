---
name: feedback-example
description: "Example feedback/lesson memory — replace with lessons learned from your own work"
metadata:
  type: feedback
---

Never use `sed` to edit crontabs in place — pipe the output to a temp file, verify it, then install with `crontab tempfile`.

**Why:** A bad sed pattern once wiped an entire crontab. The temp-file pattern makes the edit reviewable before it's live.

**How to apply:** Any time a crontab edit is needed, follow the pattern: `crontab -l > /tmp/ct.txt && [edit /tmp/ct.txt] && crontab /tmp/ct.txt`.
