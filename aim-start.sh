#!/bin/bash
# AIM — aim-start.sh
# 分层拼接上下文到终端+剪贴板
#
# aim-start.sh <project>                         L0 ~800 tok
# aim-start.sh <project> <module>                L0+L1 ~1300 tok
# aim-start.sh <project> --with memory           L0+L2 ~2800 tok
# aim-start.sh <project> <mod> --with decisions   L0+L1+L3
# aim-start.sh <project> --full                   全部
# aim-start.sh <project> --budget 2000            硬限 token 数

AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOADER="$SD/aim_loader.py"
P=""; MOD=""; WITH=""; BUDGET=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --with)   WITH="$2"; shift 2;;
        --full)   WITH="full"; shift;;
        --budget) BUDGET="$2"; shift 2;;
        *)        [ -z "$P" ] && P="$1" || MOD="$1"; shift;;
    esac
done

if [ -z "$P" ]; then
    echo "用法: aim-start.sh <project> [module] [--with memory|decisions|full] [--budget N]"
    echo ""; echo "项目:"
    ls "$AIM/projects/" 2>/dev/null || echo "  (无)"; exit 1
fi

PD="$AIM/projects/$P"
[ ! -d "$PD" ] && echo "❌ $P 不存在" && exit 1

RENDER_ARGS=(render "$P" --format plain --budget "$BUDGET")
PROTO_MODULE="$MOD"
USING_STATE=true

if [ -n "$MOD" ]; then
    USING_STATE=false
    RENDER_ARGS+=(--module "$MOD" --no-state)
fi

case "$WITH" in
    memory)
        USING_STATE=false
        RENDER_ARGS+=(--layers memory --no-state)
        ;;
    decisions)
        USING_STATE=false
        RENDER_ARGS+=(--layers decisions --no-state)
        ;;
    full)
        USING_STATE=false
        RENDER_ARGS+=(--layers memory,decisions,features,user,tools --no-state)
        ;;
esac

O="$(python3 "$LOADER" "${RENDER_ARGS[@]}")"

if $USING_STATE; then
    PROTO_MODULE="$(python3 "$LOADER" state "$P" module)"
fi

# Session Protocol (模块感知)
if [ -n "$PROTO_MODULE" ]; then
    printf -v O '%s\n- 本次涉及模块 %s，同时更新 modules/%s/CONTEXT.md:\n  - "我的理解": 本次搞清楚了什么\n  - "踩坑": 遇到的问题\n  - "关键区域": 重要代码位置\n  - 只追加新内容，不重写' \
        "$O" "$PROTO_MODULE" "$PROTO_MODULE"
fi

echo "$O"

ETOK=$(( ${#O} / 4 ))
if command -v pbcopy &>/dev/null; then echo "$O" | pbcopy
elif command -v xclip &>/dev/null; then echo "$O" | xclip -selection clipboard
elif command -v xsel &>/dev/null; then echo "$O" | xsel --clipboard; fi

echo "" >&2
echo "📋 ~${ETOK} tokens" >&2
if [ -n "$PROTO_MODULE" ]; then
    echo "🏗️  模块 $PROTO_MODULE: session 结束会提醒更新 CONTEXT.md" >&2
fi
if [ "$BUDGET" -gt 0 ]; then
    echo "💰 budget: hard limit ${BUDGET}" >&2
fi
