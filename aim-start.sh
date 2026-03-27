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

FILES=()
FILES+=("$PD/HANDOFF.md")
FILES+=("$PD/TODO.md")
[ -n "$MOD" ] && [ -f "$PD/modules/$MOD/CONTEXT.md" ] && FILES+=("$PD/modules/$MOD/CONTEXT.md")

case "$WITH" in
    memory)    [ -f "$PD/MEMORY.md" ] && FILES+=("$PD/MEMORY.md");;
    decisions) [ -f "$PD/DECISIONS.md" ] && FILES+=("$PD/DECISIONS.md");;
    full)
        [ -f "$PD/MEMORY.md" ] && FILES+=("$PD/MEMORY.md")
        [ -f "$PD/DECISIONS.md" ] && FILES+=("$PD/DECISIONS.md")
        [ -f "$PD/FEATURES.md" ] && FILES+=("$PD/FEATURES.md")
        [ -f "$AIM/global/USER.md" ] && FILES+=("$AIM/global/USER.md")
        ;;
esac

O=""; TOTAL=0
for f in "${FILES[@]}"; do
    [ ! -f "$f" ] && continue
    CONTENT=$(cat "$f")
    if [ "$BUDGET" -gt 0 ]; then
        TOKS=$(( ${#CONTENT} / 4 ))
        if [ $(( TOTAL + TOKS )) -gt "$BUDGET" ]; then
            O+=$'\n'"# [$(basename "$f") skipped: over budget]"$'\n'
            continue
        fi
        TOTAL=$(( TOTAL + TOKS ))
    fi
    O+="$CONTENT"$'\n\n---\n\n'
done

# Session Protocol (模块感知)
O+='# Session Protocol
- 结束时说 "更新 handoff" (固定格式, < 40 行)'
if [ -n "$MOD" ]; then
    O+=$'\n'"- 本次涉及模块 $MOD，同时更新 modules/$MOD/CONTEXT.md:"
    O+=$'\n'"  - \"我的理解\": 本次搞清楚了什么"
    O+=$'\n'"  - \"踩坑\": 遇到的问题"
    O+=$'\n'"  - \"关键区域\": 重要代码位置"
    O+=$'\n'"  - 只追加新内容，不重写"
fi
O+=$'\n'"- 如有重要发现请一并输出"

echo "$O"

ETOK=$(( ${#O} / 4 ))
if command -v pbcopy &>/dev/null; then echo "$O" | pbcopy
elif command -v xclip &>/dev/null; then echo "$O" | xclip -selection clipboard
elif command -v xsel &>/dev/null; then echo "$O" | xsel --clipboard; fi

echo "" >&2
echo "📋 ~${ETOK} tokens | ${#FILES[@]} files" >&2
[ -n "$MOD" ] && echo "🏗️  模块 $MOD: session 结束会提醒更新 CONTEXT.md" >&2
[ "$BUDGET" -gt 0 ] && echo "💰 budget: ${TOTAL}/${BUDGET}" >&2
