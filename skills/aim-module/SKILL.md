---
name: aim-module
description: "Use when studying, exploring, or diving into a specific module, or when user says aim module, aim-module, 深入模块, 切换模块, or 添加模块."
---

# AIM Module — Deep Dive into a Module

Add a new module or switch focus to an existing one: creates/updates CONTEXT.md, switches the L1 layer in CLAUDE.local.md, and explores the module source code.

## Resolve Project

1. Read `CLAUDE.local.md` in the current directory. Extract the AIM project name from `@~/.ai-memory/projects/<PROJECT>/` paths.
2. If not found, **default to `$(basename $PWD)`**.
3. Set `$PD = ~/.ai-memory/projects/<project>`.
4. Verify `$PD/modules/` exists. If not, tell user this project was not created with `--large` and offer to create the modules directory.

## Resolve AIM bin path

1. `~/.ai-memory/bin/` (if installed globally)
2. The directory containing this plugin's shell scripts (the repo root)

Store as `$AIM_BIN`.

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

### Step 3: Switch L1 layer in CLAUDE.local.md

Read `CLAUDE.local.md` in the project source directory. Then:

1. **Comment out** all currently active module lines (lines starting with `@` that contain `/modules/`)
2. **Uncomment** the target module's line (remove the `# ` prefix from the line containing `/modules/<module>/CONTEXT.md`)
3. If the target module line doesn't exist in CLAUDE.local.md (e.g., module was added after bridge), **add** it in the L1 section:
   ```
   @~/.ai-memory/projects/<project>/modules/<module>/CONTEXT.md
   ```

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
  - CLAUDE.local.md: L1 switched to <module>
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

- Only ONE module should be active (uncommented) in CLAUDE.local.md at a time
- CONTEXT.md grows incrementally across sessions — each `/aim-module` call adds knowledge
- For the first exploration, focus on breadth (what it does, key areas). Depth comes from actual work.
