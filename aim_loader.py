"""
AIM — Python loader for API-based LLM integration
Inject AIM memory into any model's system prompt.

Usage:
    from aim_loader import load_aim
    ctx = load_aim("my-project")                          # L0: ~800 tokens
    ctx = load_aim("my-project", module="api-server")     # L0+L1
    ctx = load_aim("my-project", layers=["memory"])       # L0+L2
    ctx = load_aim("my-project", budget=2000)             # Hard limit

    # Kimi
    messages = [
        {"role": "system", "content": f"You are helpful.\n\n{ctx}"},
        {"role": "user", "content": "继续上次的工作"},
    ]
"""

import os
from pathlib import Path

AIM = Path(os.environ.get("AI_MEMORY_ROOT", Path.home() / ".ai-memory"))

PROTOCOL = (
    "# Session Protocol\n"
    "- 结束时说 '更新 handoff' (固定格式, < 40 行)\n"
    "- 重要发现追加到 MEMORY.md"
)


def load_aim(
    project: str,
    module: str = None,
    layers: list = None,
    budget: int = 0,
) -> str:
    """Load AIM context with token budget control."""
    pd = AIM / "projects" / project
    if not pd.exists():
        return f"# AIM: project '{project}' not found"

    files = [
        ("handoff", pd / "HANDOFF.md"),
        ("todo", pd / "TODO.md"),
    ]

    if module:
        files.append(("module", pd / "modules" / module / "CONTEXT.md"))

    for layer in (layers or []):
        m = {
            "memory": pd / "MEMORY.md",
            "decisions": pd / "DECISIONS.md",
            "features": pd / "FEATURES.md",
            "user": AIM / "global" / "USER.md",
            "tools": AIM / "global" / "TOOLS.md",
        }
        if layer in m:
            files.append((layer, m[layer]))

    parts, total = [], 0
    for name, f in files:
        if not f.exists():
            continue
        text = f.read_text().strip()
        toks = len(text) // 4
        if budget > 0 and total + toks > budget:
            break
        parts.append(text)
        total += toks

    parts.append(PROTOCOL)
    return "\n\n---\n\n".join(parts)


if __name__ == "__main__":
    import sys
    p = sys.argv[1] if len(sys.argv) > 1 else ""
    m = sys.argv[2] if len(sys.argv) > 2 else None
    if not p:
        print("用法: python aim_loader.py <project> [module]")
        print("项目:", [d.name for d in (AIM / "projects").iterdir()] if (AIM / "projects").exists() else [])
    else:
        print(load_aim(p, module=m))
