---
name: aim-health
description: "Use when checking AIM memory health, running maintenance, archiving, or when user says aim health, aim-health, aim archive, aim-archive, aim 检查, 清理记忆, or 归档."
---

# AIM Health — Memory Maintenance

Run health checks, archive old sessions, prune oversized memory files, and clean up completed tasks.

## Resolve Project

1. Read `CLAUDE.local.md` in the current directory. Extract the AIM project name from `@~/.ai-memory/projects/<PROJECT>/` paths.
2. If not found, **default to `$(basename $PWD)`**.
3. Set `$PD = ~/.ai-memory/projects/<project>`.
4. Verify `$PD` exists. If not, tell user to run `/aim-onboard` first.

## Resolve AIM bin path

1. `~/.ai-memory/bin/` (if installed globally)
2. The directory containing this plugin's shell scripts (the repo root)

Store as `$AIM_BIN`.

## Workflow

### Step 1: Run health check

```bash
bash $AIM_BIN/aim-end.sh <project>
```

Show the full output to the user. Note any warnings.

### Step 2: Archive SESSION-LOG if overflowing

Count entries in `$PD/sessions/SESSION-LOG.md` (each `---` delimiter = entry boundary).

If > 10 entries:

```bash
bash $AIM_BIN/aim-archive.sh <project>
```

### Step 3: Prune MEMORY.md

Read `$PD/MEMORY.md`. Count lines in the `## Active` section (between `## Active` and `## Archived`).

If > 200 lines:
1. Identify items that are outdated, redundant, or superseded by newer entries
2. Move them to the `## Archived` section
3. Write the updated file
4. Report how many lines were moved

### Step 4: Clean TODO.md

Read `$PD/TODO.md`. Check the `## Done (keep 5)` section.

If more than 5 completed items:
1. Keep only the 5 most recent
2. Remove the rest

### Step 5: Compress HANDOFF.md if oversized

Read `$PD/HANDOFF.md`. Count lines.

If > 40 lines:
1. Rewrite to condense: merge similar context items, shorten descriptions, remove stale warnings
2. Must stay under 40 lines

### Step 6: Report

```
Health check for "<project>":

  Before → After:
  - HANDOFF.md: <N> lines → <M> lines <OK or PRUNED>
  - MEMORY.md Active: <N> lines → <M> lines <OK or PRUNED>
  - SESSION-LOG: <N> entries → <M> entries <OK or ARCHIVED>
  - TODO.md Done: <N> items → <M> items <OK or CLEANED>

  Warnings: <any remaining issues>
```

## Thresholds Reference

| File | Limit | Action |
|------|-------|--------|
| HANDOFF.md | < 40 lines | Rewrite to condense |
| MEMORY.md Active | < 200 lines | Move stale items to Archived |
| SESSION-LOG.md | ≤ 10 entries | aim-archive.sh |
| TODO.md Done | ≤ 5 items | Remove oldest |
