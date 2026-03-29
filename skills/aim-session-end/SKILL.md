---
name: aim-session-end
description: "Use when ending a work session, wrapping up, or when user says aim end, aim-end, aim session-end, aim-session-end, update handoff, 更新 handoff, 会话结束, 收工, or 保存进度."
---

# AIM Session End — Save Progress & Health Check

Captures everything learned this session into AIM memory files, then runs health checks.

<HARD-GATE>
You MUST have done actual work in this session before running this skill. If the session was just chatting with no code/file changes, tell the user there is nothing to save.
</HARD-GATE>

## Resolve Project

1. Read `CLAUDE.local.md` in the current directory. Extract the AIM project name from the `@~/.ai-memory/projects/<PROJECT>/` paths.
2. If no `CLAUDE.local.md` found, **default to `$(basename $PWD)`**.
3. Set `$PD = ~/.ai-memory/projects/<project>` (or `$AI_MEMORY_ROOT/projects/<project>`).
4. Verify `$PD` exists. If not, tell user to run `/aim-onboard` first.

## Resolve AIM bin path

Find the AIM scripts directory. Check in order, use the first that exists:
1. `~/.ai-memory/bin/` — standard install location
2. Run `which aim-init.sh` — if it's on PATH

If neither works, tell the user: "AIM scripts not found. Run `/aim-onboard` first."

Store the resolved directory as `$AIM_BIN`.

## Workflow

Follow these steps in order:

### Step 1: Update HANDOFF.md

**Overwrite** `$PD/HANDOFF.md` with current session state. MUST follow this format and constraints:

- **< 40 lines, < 600 tokens**
- **State only, no process details**
- Use the current date and your AI tool name

```markdown
# Handoff — <project>

> updated: YYYY-MM-DD HH:MM | by: claude-code | module: <current module or N/A>

## State: <one-line description of where we are>

## Progress
- [x] <completed items this session>
- [ ] <next items> <arrow on the current one>

## Context (max 5)
- <key fact 1>
- <key fact 2>

## Failed (max 3)
- <approach that didn't work: why>

## Open (max 3)
1. <unresolved question>

## Warnings (max 3)
- <things to watch out for>
```

Rules:
- Progress: check off what was done, add new items discovered
- Context: only facts that the next session NEEDS to know
- Failed: only approaches that were tried and didn't work (saves next session from repeating)
- Remove empty sections entirely (don't write "## Failed (max 3)" with nothing under it)

### Step 2: Update TODO.md

Read `$PD/TODO.md`, then update:
- Check off `[x]` tasks completed this session
- Add new tasks discovered during work
- Move completed items to "Done (keep 5)" section — keep only the 5 most recent
- Do NOT rewrite the entire structure, just update the relevant items

### Step 3: Append SESSION-LOG.md

**Append** (not overwrite) to `$PD/sessions/SESSION-LOG.md`:

```markdown

---
s: YYYY-MM-DD-HHMM
ai: claude-code
mod: <module or N/A>
---
<1-3 line summary of what was done>
<key decisions with rationale>
<lessons learned, tag with #pitfall if applicable>
```

Each entry MUST be ≤ 5 lines (excluding the metadata block).

### Step 4: Update module CONTEXT.md (if applicable)

If a specific module was worked on this session (detectable from HANDOFF.md's `module:` field or from the files you touched):

Read `$PD/modules/<module>/CONTEXT.md` and **append** (not rewrite) to the relevant sections:
- **我的理解**: what was clarified this session
- **踩坑**: issues encountered
- **关键区域**: important code locations discovered

Only add genuinely new information. Do not repeat what is already there.

### Step 5: Run health check

```bash
bash $AIM_BIN/aim-end.sh <project>
```

Show the output to the user.

### Step 6: Auto-archive if needed

If the health check shows SESSION-LOG > 10 entries, or if you can detect it yourself:

```bash
bash $AIM_BIN/aim-archive.sh <project>
```

### Step 7: Report

Briefly summarize what was saved:

```
Session saved for "<project>":
  - HANDOFF.md: updated (state: <state>)
  - TODO.md: <N> completed, <M> added
  - SESSION-LOG: entry appended
  - Module <name>: CONTEXT.md updated (if applicable)
  - Health: <pass/warnings>
```

## Important Rules

- HANDOFF.md is **overwritten** each time (it is a snapshot, not a log)
- SESSION-LOG.md is **appended** to (it is a log)
- TODO.md is **edited in place** (check/uncheck items, add new ones)
- Module CONTEXT.md is **appended** to (incremental knowledge growth)
- Never exceed the line limits: HANDOFF < 40, SESSION-LOG entry ≤ 5 lines
