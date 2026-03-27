#!/bin/bash
# AIM — aim-end.sh <project>
# Session 结束检查，含模块 CONTEXT.md 更新检测
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
P="$1"
[ -z "$P" ] && echo "用法: aim-end.sh <project>" && exit 1
PD="$AIM/projects/$P"
[ ! -d "$PD" ] && echo "❌ $P 不存在" && exit 1

echo "📋 Session 结束检查 — $P"
echo ""

ck() {
    local f="$1" n="$2"
    if [ -f "$f" ]; then
        local mt; mt=$(stat -f%m "$f" 2>/dev/null || stat -c%Y "$f" 2>/dev/null || echo 0)
        local age=$(( ($(date +%s) - mt) / 60 ))
        [ "$age" -lt 10 ] && echo "  ✅ $n (${age}m ago)" || echo "  ⚠️  $n (${age}m ago)"
    else echo "  ❌ $n (不存在)"; fi
}

ck "$PD/HANDOFF.md" "HANDOFF.md"
ck "$PD/TODO.md" "TODO.md"
ck "$PD/sessions/SESSION-LOG.md" "SESSION-LOG.md"

# HANDOFF 行数
if [ -f "$PD/HANDOFF.md" ]; then
    lines=$(wc -l < "$PD/HANDOFF.md" | tr -d ' ')
    [ "$lines" -gt 40 ] && echo "  ⚠️  HANDOFF.md: ${lines} 行 (上限 40)"
fi

# 模块 CONTEXT.md 检查:
# 读取 HANDOFF.md 的 module 字段, 检查对应的 CONTEXT.md 是否更新
if [ -f "$PD/HANDOFF.md" ] && [ -d "$PD/modules" ]; then
    # 从 HANDOFF 提取 module 字段
    MOD=$(grep -oP '(?<=module: )\S+' "$PD/HANDOFF.md" 2>/dev/null || true)

    if [ -n "$MOD" ] && [ "$MOD" != "N/A" ] && [ "$MOD" != "-" ]; then
        CTX="$PD/modules/$MOD/CONTEXT.md"
        if [ -f "$CTX" ]; then
            # 检查是否还是空模板 (只有 TODO 标记)
            real_content=$(grep -v '^\s*$\|^#\|^-\|^\[TODO\]\|^(待积累)\|^---' "$CTX" 2>/dev/null | head -1)
            has_todo=$(grep -c '\[TODO\]' "$CTX" 2>/dev/null); has_todo=${has_todo:-0}

            if [ -z "$real_content" ] || [ "$has_todo" -gt 2 ]; then
                echo ""
                echo "  📝 本次 session 涉及模块 [$MOD]，但 CONTEXT.md 仍是空模板"
                echo "     → 让 AI 更新: $CTX"
                echo "     → prompt: \"把这次关于 $MOD 学到的更新到模块 CONTEXT\""
            else
                ck "$CTX" "modules/$MOD/CONTEXT.md"
            fi
        elif [ -d "$PD/modules/$MOD" ]; then
            ck "$CTX" "modules/$MOD/CONTEXT.md"
        fi
    fi
fi

# MEMORY Active 行数
if [ -f "$PD/MEMORY.md" ]; then
    active=$(sed -n '/^## Active/,/^---$/p' "$PD/MEMORY.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$active" -gt 200 ]; then
        echo "  ⚠️  MEMORY.md Active: ${active} 行 (上限 200)"
    else
        echo "  ✅ MEMORY.md Active: ${active} 行"
    fi
fi

# FEATURES 进度
if [ -f "$PD/FEATURES.md" ]; then
    total=$(grep -c '^\- \[' "$PD/FEATURES.md" 2>/dev/null); total=${total:-0}
    done=$(grep -c '^\- \[x\]' "$PD/FEATURES.md" 2>/dev/null); done=${done:-0}
    echo "  📊 FEATURES: $done/$total"
fi

# SESSION-LOG 溢出
if [ -f "$PD/sessions/SESSION-LOG.md" ]; then
    entries=$(grep -c '^---$' "$PD/sessions/SESSION-LOG.md" 2>/dev/null); entries=${entries:-0}
    entries=$(( entries / 2 ))
    [ "$entries" -gt 10 ] && echo "" && echo "  📦 SESSION-LOG: ${entries} 条 (上限 10) → aim-archive.sh $P"
fi

# TODO 完成项
if [ -f "$PD/TODO.md" ]; then
    done_n=$(grep -c '^\- \[x\]' "$PD/TODO.md" 2>/dev/null); done_n=${done_n:-0}
    [ "$done_n" -gt 5 ] && echo "  🧹 TODO: ${done_n} 个完成项 (保留 5 个)"
fi
