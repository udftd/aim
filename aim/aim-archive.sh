#!/bin/bash
# AIM — aim-archive.sh <project> [--keep N]
# 归档 SESSION-LOG.md 中溢出的条目到 archive/YYYY-MM.md
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
P="$1"; KEEP=10
[ "$2" = "--keep" ] && KEEP="$3"
[ -z "$P" ] && echo "用法: aim-archive.sh <project> [--keep N]" && exit 1

PD="$AIM/projects/$P"
LOG="$PD/sessions/SESSION-LOG.md"
[ ! -f "$LOG" ] && echo "❌ SESSION-LOG.md 不存在" && exit 1

mkdir -p "$PD/sessions/archive"
MONTH=$(date +%Y-%m)
ARCH="$PD/sessions/archive/$MONTH.md"

python3 -c "
import re
with open('$LOG') as f:
    content = f.read()
parts = re.split(r'\n---\n', content)
header = parts[0]
entries = [p for p in parts[1:] if p.strip()]
keep = $KEEP
if len(entries) <= keep:
    print(f'✅ {len(entries)} 条 (上限 {keep})，无需归档')
    exit(0)
to_arch = entries[:-keep]
to_keep = entries[-keep:]
with open('$ARCH', 'a') as f:
    for e in to_arch:
        f.write('\n---\n' + e)
with open('$LOG', 'w') as f:
    f.write(header)
    for e in to_keep:
        f.write('\n---\n' + e)
    f.write('\n')
print(f'📦 归档 {len(to_arch)} 条 → archive/$MONTH.md')
print(f'✅ 保留 {len(to_keep)} 条')
" 2>/dev/null || {
    echo "⚠️  需要 python3。"
    entries=$(grep -c '^---$' "$LOG" 2>/dev/null || echo 0)
    entries=$(( entries / 2 ))
    echo "   SESSION-LOG 有 ~$entries 条，请手动移旧条目到 $ARCH"
}
