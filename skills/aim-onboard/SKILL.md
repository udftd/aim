---
name: aim-onboard
description: "Use when setting up AIM memory for a new project, onboarding to a codebase, or when user says aim init, aim-init, aim onboard, aim-onboard, or wants persistent AI memory for a project."
---

# AIM Onboard — Project Initialization

One-command setup: creates AIM project, auto-fills PROJECT.md, generates bridge files, and discovers modules.

## Resolve AIM bin path

Find the AIM scripts directory. Check in order, use the first that exists:
1. `~/.ai-memory/bin/` — standard install location
2. Run `which aim-init.sh` — if it's on PATH

If neither works, tell the user: "AIM scripts not found. Run `bash aim-init.sh` from the AIM repo first."

Store the resolved directory as `$AIM_BIN` for all subsequent commands.

## Workflow

You MUST follow these steps in order:

### Step 1: Resolve project name and parameters

- If user provided a project name, use it
- **If not provided, default to `$(basename $PWD)`**
- Detect mode: if user says "study", "learn", "read", "take over", "onboard" → `--study`; otherwise `--dev`
- Detect scale: count top-level directories in current project. If > 15 → suggest `--large`
- Confirm with user: "Project: `<name>`, mode: `<mode>`, large: `<yes/no>`. OK?"

### Step 2: Global init (if needed)

Check if `~/.ai-memory/global/` exists. If not:

```bash
bash $AIM_BIN/aim-init.sh
```

### Step 3: Create project

```bash
bash $AIM_BIN/aim-init.sh <project> [--study] [--large]
```

If the project already exists, skip this step and inform the user.

### Step 4: Auto-fill PROJECT.md

This is the key advantage over running the script manually. Read the target project's files to gather info:

1. **Read** README.md (or README, README.rst) for project description
2. **Read** package.json / go.mod / Cargo.toml / pyproject.toml / pom.xml / build.gradle for tech stack and build commands
3. **Read** Makefile / Justfile / Taskfile.yml for build/test/dev commands
4. **Check** if CLAUDE.md, AGENTS.md, .clinerules exist in the project directory

Then **overwrite** `~/.ai-memory/projects/<project>/PROJECT.md` with the filled template:

```markdown
# Project: <name>
- **一句话描述**: <extracted from README or package.json description>
- **代码路径**: <absolute path to project>
- **技术栈**: <detected languages, frameworks, key dependencies>
- **项目规模**: <small/medium/large>
- **我的角色**: <研读学习 if --study, 开发 if --dev>
## 项目已有的 AI 配置
- CLAUDE.md: <有/无>
- AGENTS.md: <有/无>
- .clinerules: <有/无>
## Build & Run
- Install: `<detected install command>`
- Dev: `<detected dev command>`
- Test: `<detected test command>`
## 快速上下文
<2-3 sentences summarizing the project based on README>
```

### Step 5: Run bridge

```bash
bash $AIM_BIN/aim-bridge.sh <project> <project-code-path> --tools claude,codex
```

Where `<project-code-path>` is the current working directory (or user-specified path).

### Step 6: Module discovery (only if --large)

If the project was created with `--large`:

1. **Scan** the top-level directory structure of the project
2. **Identify** candidate modules: major directories that represent distinct subsystems (e.g., `cmd/`, `pkg/`, `internal/`, `src/components/`, `server/`, `client/`)
3. **Propose** the module list to the user, explaining what each one likely contains
4. After user confirms, run for each approved module:

```bash
bash $AIM_BIN/aim-add-module.sh <project> <module-name>
```

5. Do NOT auto-fill CONTEXT.md at this stage — that is the job of `/aim-module`

### Step 7: Summary

Output a summary of what was created:

```
AIM project "<name>" initialized:
  - PROJECT.md: auto-filled
  - Bridge: CLAUDE.local.md + AGENTS.override.md
  - Modules: <list or "none (not --large)">

Next steps:
  - Review PROJECT.md: ~/.ai-memory/projects/<name>/PROJECT.md
  - (If large) Deep-dive modules: /aim-module <module-name>
  - Start working — memory auto-loads via CLAUDE.local.md
  - End session: /aim-session-end
```

## Error Handling

- If `aim-init.sh` fails because project exists: inform user, ask if they want to re-run bridge only
- If no README or package.json found: fill PROJECT.md with [TODO] markers and tell user to complete manually
- If bridge fails: show the error output and suggest checking the project path
