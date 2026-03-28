---
name: aim-search
description: "Use when searching AIM memory files, looking for past decisions or session history, or when user says aim search, aim-search, 搜索记忆, 之前决定了什么, or 历史里有没有."
---

# AIM Search — Search Memory Files

Search across AIM memory files and interpret the results in context.

## Resolve Project

1. Read `CLAUDE.local.md` in the current directory. Extract the AIM project name from `@~/.ai-memory/projects/<PROJECT>/` paths.
2. If not found, **default to `$(basename $PWD)`**.
3. If user says "search all" or "global search", search across all projects (omit the project argument).

## Resolve AIM bin path

1. `~/.ai-memory/bin/` (if installed globally)
2. The directory containing this plugin's shell scripts (the repo root)

Store as `$AIM_BIN`.

## Workflow

### Step 1: Parse the query

Extract from the user's message:
- **Search term**: the keyword or phrase to search for
- **Scope**: specific project or all projects
- **Type filter** (optional): `sessions`, `memory`, or `decisions`
  - If user asks about "past decisions" or "why did we" → `--type decisions`
  - If user asks about "last session" or "when did we" → `--type sessions`
  - If user asks about "what do we know" or "background on" → `--type memory`
  - Otherwise: no type filter (search all .md files)

### Step 2: Execute search

```bash
bash $AIM_BIN/aim-search.sh "<query>" [project] [--type <type>]
```

### Step 3: Interpret results

Don't just dump the raw output. Instead:

1. **Group** results by file (HANDOFF, MEMORY, DECISIONS, SESSION-LOG, module CONTEXT, etc.)
2. **Summarize** what was found: when it was recorded, in what context
3. **Highlight** the most relevant matches
4. If searching session history: provide a **timeline** of related work
5. If searching decisions: show the **full ADR** (read the file if needed for more context)

### Step 4: Suggest follow-up

Based on results:
- "Want me to read the full decision record?" (if found in DECISIONS.md)
- "Want me to check the archived sessions for older history?" (if no results in current SESSION-LOG)
- "No results found. Try searching with different terms, or check archived sessions."

## Example Interactions

User: "aim-search webhook timeout"
→ Search for "webhook timeout" in current project, all file types
→ Show results from DECISIONS.md (ADR about timeout config), SESSION-LOG (when it was debugged), MEMORY.md (lesson learned)

User: "之前为什么选了 PostgreSQL"
→ Search for "PostgreSQL" with `--type decisions`
→ Show the relevant ADR with full context

User: "搜索记忆 authentication"
→ Search for "authentication" in current project, all file types
→ Group and summarize findings
