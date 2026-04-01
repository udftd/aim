#!/bin/bash
# AIM — aim-bridge.sh
# aim-bridge.sh <project> [path] [--tools claude,codex,cline,roo,cursor,copilot,all]
set -e
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOADER="$SD/aim_loader.py"
G='\033[0;32m' C='\033[0;36m' Y='\033[1;33m' R='\033[0;31m' D='\033[2m' N='\033[0m'

P="$1"; PP="${2:-.}"; T=""
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do case $1 in --tools) T="$2"; shift 2;; *) shift;; esac; done
[ -z "$T" ] && T="all"

if [ -z "$P" ]; then
    echo "用法: aim-bridge.sh <project> [path] [--tools claude,codex,cline,roo,cursor,copilot,all]"
    echo ""; echo "已有项目:"
    ls "$AIM/projects/" 2>/dev/null || echo "  (无)"
    echo ""; echo "项目不存在? 先: aim-init.sh <project> [--study] [--large]"
    exit 1
fi

PD="$AIM/projects/$P"
STATE="$PD/LAYER_STATE.json"

if [ ! -d "$PD" ]; then
    echo -e "${Y}⚠️  AIM 项目 '$P' 不存在${N}"
    echo "先运行: aim-init.sh $P [--study] [--large]"
    exit 1
fi

MISSING=""
for f in HANDOFF.md TODO.md MEMORY.md; do
    [ ! -f "$PD/$f" ] && MISSING="$MISSING $f"
done
[ -n "$MISSING" ] && echo -e "${R}❌ '$P' 缺少:$MISSING${N}" && exit 1

[ -f "$STATE" ] || cat > "$STATE" << 'EOF'
{
  "module": null,
  "layers": []
}
EOF

MODS=$(find "$PD/modules" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -I{} basename {} | sort)
HAS_MODS=false; [ -n "$MODS" ] && HAS_MODS=true
ACTIVE_MODULE="$(python3 "$LOADER" state "$P" module)"
mapfile -t ACTIVE_LAYERS < <(python3 "$LOADER" state "$P" layers)

has_layer() {
    local target="$1"
    local layer
    for layer in "${ACTIVE_LAYERS[@]}"; do
        [ "$layer" = "$target" ] && return 0
    done
    return 1
}

echo -e "${C}🔗 AIM bridge: $P${N}"
echo -e "${D}   项目: $(cd "$PP" 2>/dev/null && pwd)  记忆: $PD${N}"
echo -e "${D}   状态: module=${ACTIVE_MODULE:-none} layers=${ACTIVE_LAYERS[*]:-none}${N}"

ok() { [[ "$T" == "all" ]] || [[ ",$T," == *",$1,"* ]]; }
gi() {
    [ -f "$PP/.gitignore" ] || return 0
    grep -qxF "$1" "$PP/.gitignore" 2>/dev/null && return 0
    echo "$1" >> "$PP/.gitignore"
}

# ── 工作流指令 (所有桥接文件共享) ──
WF='Session 结束时说 "更新 handoff":
- 覆盖 HANDOFF.md (< 40 行, 只写状态不写过程)
- 更新 TODO.md checklist
- 追加 sessions/SESSION-LOG.md (≤ 5 行, 格式: ---/s: 日期时间/ai: 工具名/mod: 模块/---/摘要)'

if $HAS_MODS; then
    WF="$WF
- 如果本次深入了某个模块, 同时更新该模块的 CONTEXT.md:
  \"我的理解\" 追加搞清楚了什么
  \"踩坑\" 追加遇到的坑
  \"关键区域\" 追加发现的重要代码位置
  (增量追加, 不全量重写)"
fi

# ── Claude Code ──
if ok claude; then
    F="$PP/CLAUDE.local.md"
    {
        echo "# CLAUDE.local.md — AIM Bridge"
        echo ""
        echo "# ── L0: 每次 (~800 tok) ──"
        echo "@$PD/HANDOFF.md"
        echo "@$PD/TODO.md"
        if $HAS_MODS; then
            echo ""
            echo "# ── L1: 模块 (切换时改, 同时只启用一个) ──"
            for m in $MODS; do
                if [ "$m" = "$ACTIVE_MODULE" ]; then
                    echo "@$PD/modules/$m/CONTEXT.md"
                else
                    echo "<!-- inactive import: $PD/modules/$m/CONTEXT.md -->"
                fi
            done
        fi
        echo ""
        echo "# ── L2: 背景 ──"
        if has_layer memory; then echo "@$PD/MEMORY.md"; else echo "<!-- inactive import: $PD/MEMORY.md -->"; fi
        echo ""
        echo "# ── L3: 架构/特性 ──"
        if has_layer decisions; then echo "@$PD/DECISIONS.md"; else echo "<!-- inactive import: $PD/DECISIONS.md -->"; fi
        if has_layer features; then echo "@$PD/FEATURES.md"; else echo "<!-- inactive import: $PD/FEATURES.md -->"; fi
        echo ""
        echo "# ── L4: 切换 AI 时 ──"
        if has_layer user; then echo "@$AIM/global/USER.md"; else echo "<!-- inactive import: $AIM/global/USER.md -->"; fi
        if has_layer tools; then echo "@$AIM/global/TOOLS.md"; else echo "<!-- inactive import: $AIM/global/TOOLS.md -->"; fi
        echo ""
        echo "# ── 工作流 ──"
        echo "$WF"
    } > "$F"
    gi "CLAUDE.local.md"
    echo -e "  ${G}✓ Claude Code${N}  CLAUDE.local.md"
fi

# ── Codex CLI ──
if ok codex; then
    {
        echo "# AGENTS.override.md — AIM Bridge"
        echo "> generated from $STATE"
        echo ""
        python3 "$LOADER" render "$P" --format codex
        echo ""
        echo "## Protocol"
        echo "$WF"
    } > "$PP/AGENTS.override.md"
    gi "AGENTS.override.md"
    echo -e "  ${G}✓ Codex CLI${N}    AGENTS.override.md"
fi

# ── Cline ──
if ok cline; then
    mkdir -p "$PP/.clinerules"
    ln -sf "$PD/HANDOFF.md" "$PP/.clinerules/aim-00-handoff.md"
    ln -sf "$PD/TODO.md" "$PP/.clinerules/aim-01-todo.md"
    {
        echo "# AIM Protocol"
        echo "$WF"
        echo "Paths: HANDOFF=$PD/HANDOFF.md TODO=$PD/TODO.md"
        $HAS_MODS && echo "Modules: $PD/modules/<name>/CONTEXT.md"
    } > "$PP/.clinerules/aim-99-workflow.md"
    gi ".clinerules/aim-*"
    echo -e "  ${G}✓ Cline${N}        .clinerules/aim-*"
fi

# ── Roo Code ──
if ok roo; then
    mkdir -p "$PP/.roo/rules"
    ln -sf "$PD/HANDOFF.md" "$PP/.roo/rules/aim-00-handoff.md"
    ln -sf "$PD/TODO.md" "$PP/.roo/rules/aim-01-todo.md"
    {
        echo "# AIM Protocol"
        echo "$WF"
        echo "Paths: HANDOFF=$PD/HANDOFF.md TODO=$PD/TODO.md"
        $HAS_MODS && echo "Modules: $PD/modules/<name>/CONTEXT.md"
    } > "$PP/.roo/rules/aim-99-workflow.md"
    gi ".roo/rules/aim-*"
    echo -e "  ${G}✓ Roo Code${N}     .roo/rules/aim-*"
fi

# ── Cursor ──
if ok cursor; then
    mkdir -p "$PP/.cursor/rules"
    {
        echo "---"
        echo "description: AIM work context"
        echo "globs:"
        echo "alwaysApply: true"
        echo "---"
        echo "Read $PD/HANDOFF.md and $PD/TODO.md at start."
        echo ""
        echo "$WF"
    } > "$PP/.cursor/rules/aim-memory.mdc"
    ln -sf "$PD/HANDOFF.md" "$PP/.cursor/rules/aim-handoff.md"
    ln -sf "$PD/TODO.md" "$PP/.cursor/rules/aim-todo.md"
    gi ".cursor/rules/aim-*"
    echo -e "  ${G}✓ Cursor${N}       .cursor/rules/aim-*"
fi

# ── Copilot ──
if ok copilot; then
    mkdir -p "$PP/.github"
    {
        echo "# AIM Context"
        echo "Read $PD/HANDOFF.md and $PD/TODO.md at start."
        echo ""
        echo "$WF"
    } > "$PP/.github/aim-instructions.md"
    [ ! -f "$PP/.github/copilot-instructions.md" ] && \
        ln -sf "aim-instructions.md" "$PP/.github/copilot-instructions.md"
    gi ".github/aim-*"
    echo -e "  ${G}✓ Copilot${N}      .github/aim-instructions.md"
fi

echo -e "\n${G}✅ 桥接完成${N}"
if $HAS_MODS; then
    echo -e "${D}🏗️  modules/: $MODS${N}"
    echo -e "${D}   当前激活模块: ${ACTIVE_MODULE:-none}${N}"
    echo -e "${D}   session 结束时 AI 会同时更新模块 CONTEXT.md${N}"
fi
echo -e "${D}   分层状态文件: $STATE${N}"
echo -e "${Y}💡 下次打开 AI 工具时记忆自动加载${N}"
