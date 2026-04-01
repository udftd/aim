"""
AIM — shared layer resolver and loader

Inject AIM memory into prompts, and render bridge-friendly content for tools
that do not support dynamic imports.
"""

import argparse
import json
import os
import sys
from pathlib import Path

AIM = Path(os.environ.get("AI_MEMORY_ROOT", Path.home() / ".ai-memory"))
STATE_FILE = "LAYER_STATE.json"
OPTIONAL_LAYERS = ("memory", "decisions", "features", "user", "tools")
LAYER_PATHS = {
    "memory": ("MEMORY", lambda pd: pd / "MEMORY.md"),
    "decisions": ("DECISIONS", lambda pd: pd / "DECISIONS.md"),
    "features": ("FEATURES", lambda pd: pd / "FEATURES.md"),
    "user": ("USER", lambda pd: AIM / "global" / "USER.md"),
    "tools": ("TOOLS", lambda pd: AIM / "global" / "TOOLS.md"),
}
BASE_ENTRIES = (
    ("handoff", "HANDOFF", lambda pd: pd / "HANDOFF.md"),
    ("todo", "TODO", lambda pd: pd / "TODO.md"),
)
PROTOCOL = (
    "# Session Protocol\n"
    '- 结束时说 "更新 handoff" (固定格式, < 40 行)\n'
    "- 重要发现追加到 MEMORY.md"
)


def project_dir(project: str) -> Path:
    return AIM / "projects" / project


def state_path(project: str) -> Path:
    return project_dir(project) / STATE_FILE


def default_state() -> dict:
    return {"module": None, "layers": []}


def normalize_layers(layers) -> list:
    if layers is None:
        return None

    if isinstance(layers, str):
        raw = [part.strip() for part in layers.split(",")]
    else:
        raw = [str(part).strip() for part in layers]

    out = []
    for layer in raw:
        if not layer or layer not in OPTIONAL_LAYERS or layer in out:
            continue
        out.append(layer)
    return out


def load_state(project: str) -> dict:
    path = state_path(project)
    if not path.exists():
        return default_state()

    try:
        data = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return default_state()

    module = data.get("module")
    if not isinstance(module, str) or not module.strip():
        module = None
    else:
        module = module.strip()

    layers = normalize_layers(data.get("layers", [])) or []
    return {"module": module, "layers": layers}


def resolve_selection(
    project: str,
    module: str = None,
    layers=None,
    use_state: bool = True,
) -> dict:
    pd = project_dir(project)
    if not pd.exists():
        return {"module": None, "layers": []}

    state = load_state(project) if use_state else default_state()
    selected_module = module if module is not None else state["module"]
    selected_layers = normalize_layers(layers) if layers is not None else state["layers"]

    if selected_module and not (pd / "modules" / selected_module / "CONTEXT.md").exists():
        selected_module = None

    return {
        "module": selected_module,
        "layers": selected_layers or [],
    }


def resolve_entries(
    project: str,
    module: str = None,
    layers=None,
    use_state: bool = True,
):
    pd = project_dir(project)
    if not pd.exists():
        return []

    selection = resolve_selection(project, module=module, layers=layers, use_state=use_state)
    entries = []

    for key, title, path_fn in BASE_ENTRIES:
        path = path_fn(pd)
        if path.exists():
            entries.append({"key": key, "title": title, "path": path})

    if selection["module"]:
        path = pd / "modules" / selection["module"] / "CONTEXT.md"
        if path.exists():
            entries.append(
                {
                    "key": "module",
                    "title": f"MODULE {selection['module']}",
                    "path": path,
                }
            )

    for layer in selection["layers"]:
        title, path_fn = LAYER_PATHS[layer]
        path = path_fn(pd)
        if path.exists():
            entries.append({"key": layer, "title": title, "path": path})

    return entries


def render_plain(
    project: str,
    module: str = None,
    layers=None,
    budget: int = 0,
    use_state: bool = True,
) -> str:
    parts = []
    total = 0

    for entry in resolve_entries(project, module=module, layers=layers, use_state=use_state):
        text = entry["path"].read_text().strip()
        toks = len(text) // 4
        if budget > 0 and total + toks > budget:
            parts.append(f"# [{entry['path'].name} skipped: over budget]")
            continue
        parts.append(text)
        total += toks

    parts.append(PROTOCOL)
    return "\n\n---\n\n".join(parts)


def render_codex(project: str, module: str = None, layers=None, use_state: bool = True) -> str:
    blocks = []

    for entry in resolve_entries(project, module=module, layers=layers, use_state=use_state):
        text = entry["path"].read_text().strip()
        blocks.append(
            "\n".join(
                [
                    f"## AIM: {entry['title']}",
                    f"> source: {entry['path']}",
                    "",
                    text,
                ]
            )
        )

    return "\n\n---\n\n".join(blocks).strip()


def load_aim(
    project: str,
    module: str = None,
    layers: list = None,
    budget: int = 0,
    use_state: bool = True,
) -> str:
    """Load AIM context with optional shared-state resolution and token budget control."""
    pd = project_dir(project)
    if not pd.exists():
        return f"# AIM: project '{project}' not found"

    return render_plain(
        project,
        module=module,
        layers=layers,
        budget=budget,
        use_state=use_state,
    )


def build_parser():
    parser = argparse.ArgumentParser(prog="aim_loader.py")
    sub = parser.add_subparsers(dest="command")

    state_cmd = sub.add_parser("state")
    state_cmd.add_argument("project")
    state_cmd.add_argument("field", nargs="?", choices=("json", "module", "layers"))

    render_cmd = sub.add_parser("render")
    render_cmd.add_argument("project")
    render_cmd.add_argument("--module")
    render_cmd.add_argument("--layers")
    render_cmd.add_argument("--budget", type=int, default=0)
    render_cmd.add_argument("--format", choices=("plain", "codex"), default="plain")
    render_cmd.add_argument("--no-state", action="store_true")

    return parser


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "state":
        state = resolve_selection(args.project)
        field = args.field or "json"
        if field == "json":
            print(json.dumps(state, ensure_ascii=True))
        elif field == "module":
            print(state["module"] or "")
        elif field == "layers":
            if state["layers"]:
                print("\n".join(state["layers"]))
        return 0

    if args.command == "render":
        use_state = not args.no_state
        layers = normalize_layers(args.layers) if args.layers is not None else None
        if args.format == "plain":
            print(
                render_plain(
                    args.project,
                    module=args.module,
                    layers=layers,
                    budget=args.budget,
                    use_state=use_state,
                )
            )
        else:
            print(
                render_codex(
                    args.project,
                    module=args.module,
                    layers=layers,
                    use_state=use_state,
                )
            )
        return 0

    if len(sys.argv) == 1:
        parser.print_help()
        return 0

    parser.error("unknown command")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
