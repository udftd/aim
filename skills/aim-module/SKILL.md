---
name: aim-module
description: "Use when studying, exploring, or diving into a specific module, or when user says aim module, aim-module, 深入模块, 切换模块, or 添加模块."
---

# AIM Module — Deep Dive into a Module

Add a new module or switch focus to an existing one: creates/updates CONTEXT.md, switches the shared L1 state, regenerates bridge files, and explores the module source code.

## Resolve Project

1. Read `AGENTS.override.md` in the current directory. If it contains a `generated from ~/.ai-memory/projects/<PROJECT>/` or `source: ~/.ai-memory/projects/<PROJECT>/` path, extract the AIM project name.
2. If not found, read `CLAUDE.local.md` in the current directory and extract the AIM project name from `@~/.ai-memory/projects/<PROJECT>/` paths.
3. If neither bridge file identifies the project, **default to `$(basename $PWD)`**.
4. Set `$PD = ~/.ai-memory/projects/<project>`.
5. Verify `$PD/modules/` exists. If not, tell user this project was not created with `--large` and offer to create the modules directory.

## Resolve AIM bin path

Find the AIM scripts directory. Check in order, use the first that exists:
1. `~/.ai-memory/bin/` — standard install location
2. Run `which aim-init.sh` — if it's on PATH

If neither works, tell the user: "AIM scripts not found. Run the aim-onboard workflow first."

Store the resolved directory as `$AIM_BIN`.

## Workflow

### Step 1: Identify target module

- If user specified a module name, use it
- If not, check `$PD/modules/_INDEX.md` for existing modules
  - If modules exist: list them with their familiarity level, ask which one to focus on
  - If no modules exist: scan the project's top-level directory structure, propose candidates, ask user to pick

### Step 2: Create module (if it doesn't exist)

```bash
bash $AIM_BIN/aim-add-module.sh <project> <module>
```

### Step 3: Switch shared L1 state

Read `~/.ai-memory/projects/<project>/LAYER_STATE.json`. Then:

1. Set `"module"` to `<module>`
2. Preserve existing `"layers"` values
3. Re-run `aim-bridge.sh <project> <project-path> --tools claude,codex`

Use the Edit tool for precise modifications.

### Step 4: Explore and fill CONTEXT.md

This is the core value of the skill. Read the module's source code to understand it:

1. **Identify the module's directory** in the source code (use hints from _INDEX.md or ask user)
2. **Read key files**: entry points, main types/interfaces, README if exists
3. **Analyze**: what it does, key exports, dependencies, who depends on it

Then **update** `$PD/modules/<module>/CONTEXT.md`:

```markdown
---
project: <project>
module: <module>
tags: [<relevant tags>]
---
# Module: <module>

## 是什么
<one paragraph: what this module does, its responsibility>

## 关键区域
- <capability 1>: <what it does, key files involved>
- <capability 2>: <what it does, key files involved>

## 我的理解
- <clear>: <things you now understand>
- <unclear>: <things that need more investigation>

## 踩坑
(none yet, or any gotchas discovered)

## 关联
- 依赖: <modules/packages this depends on>
- 被依赖: <modules/packages that depend on this>
```

If CONTEXT.md already has content, **append** new findings to existing sections rather than overwriting.

### Step 5: Update _INDEX.md

Read `$PD/modules/_INDEX.md` and update the module's row:

| 模块 | 路径提示 | 熟悉度 | 最近 |
|------|---------|--------|------|
| <module> | <source path hint> | <low/medium/high> | <today's date> |

- If the module row doesn't exist, add it
- If it exists, update 熟悉度 and 最近 fields
- Familiarity levels: `low` (just created), `medium` (explored key areas), `high` (deep understanding)

### Step 6: Report

```
Module "<module>" activated:
  - CONTEXT.md: <filled/updated>
  - LAYER_STATE.json: module switched to <module>
  - CLAUDE.local.md / AGENTS.override.md: regenerated
  - _INDEX.md: updated

Key findings:
  - <what the module does>
  - <important patterns/gotchas>

Still unclear:
  - <what needs more investigation>

Suggestions:
  - <next module to explore, or specific code to read>
```

## Notes

- Only ONE module should be active in `LAYER_STATE.json` at a time
- CONTEXT.md grows incrementally across sessions — each aim-module run adds knowledge
- For the first exploration, focus on breadth (what it does, key areas). Depth comes from actual work.
