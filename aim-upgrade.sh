#!/bin/bash
# AIM — aim-upgrade.sh
# 仓库维护工具，只在 aim repo 目录下运行，更新 ~/.ai-memory/bin/ 中的脚本
#
# aim-upgrade.sh                    从记住的 source 升级
# aim-upgrade.sh --source <path>    指定/覆盖 source 路径
# aim-upgrade.sh --check            只检查，不执行
# aim-upgrade.sh --force            无视版本号，强制更新脚本
set -e
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
G='\033[0;32m' C='\033[0;36m' Y='\033[1;33m' R='\033[0;31m' D='\033[2m' N='\033[0m'

SOURCE=""; CHECK=false; FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --source) SOURCE="$2"; shift 2;;
        --check)  CHECK=true; shift;;
        --force)  FORCE=true; shift;;
        *)        shift;;
    esac
done

# ── 1. 解析 source 路径 ──
META="$AIM/.aim-meta"
if [ -z "$SOURCE" ] && [ -f "$META" ]; then
    SOURCE=$(grep '^source=' "$META" 2>/dev/null | cut -d= -f2-)
fi
if [ -z "$SOURCE" ]; then
    echo -e "${R}❌ 未知 source 路径${N}"
    echo "首次使用请指定: aim-upgrade.sh --source <aim-repo-path>"
    exit 1
fi

# ── 2. 验证 source ──
if [ ! -f "$SOURCE/aim-init.sh" ]; then
    echo -e "${R}❌ 不是有效的 AIM 仓库: $SOURCE${N}"
    echo "找不到 aim-init.sh"
    exit 1
fi
if [ ! -f "$SOURCE/VERSION" ]; then
    echo -e "${R}❌ $SOURCE/VERSION 不存在${N}"
    echo "请先在 AIM 仓库运行 git pull"
    exit 1
fi

# ── 3. 读取版本 ──
INSTALLED="0.0"
[ -f "$META" ] && INSTALLED=$(grep '^version=' "$META" 2>/dev/null | cut -d= -f2- || echo "0.0")
AVAILABLE=$(cat "$SOURCE/VERSION" | tr -d '[:space:]')

echo -e "${C}🔄 AIM upgrade${N}"
echo -e "${D}   source:    $SOURCE${N}"
echo -e "${D}   installed: v$INSTALLED${N}"
echo -e "${D}   available: v$AVAILABLE${N}"
echo ""

# ── 4. 比较版本 ──
if [ "$INSTALLED" = "$AVAILABLE" ] && ! $FORCE; then
    echo -e "${G}✅ 已是最新 (v$AVAILABLE)${N}"
    exit 0
fi

# ── 5. 显示 changelog ──
if [ "$INSTALLED" != "$AVAILABLE" ] && [ -f "$SOURCE/CHANGELOG.md" ]; then
    echo -e "${Y}📋 变更记录 (v$INSTALLED → v$AVAILABLE):${N}"
    echo ""
    awk -v inst="$INSTALLED" -v avail="$AVAILABLE" '
        /^## / {
            ver = $2
            if (ver == inst) { printing = 0 }
            else if (printing || ver == avail) { printing = 1 }
        }
        printing { print "  " $0 }
    ' "$SOURCE/CHANGELOG.md"
    echo ""
elif $FORCE; then
    echo -e "${D}(--force: 跳过版本检查，强制更新脚本)${N}"
    echo ""
fi

# ── 6. 如果只检查 ──
if $CHECK; then
    echo -e "${Y}💡 运行 aim-upgrade.sh 执行升级${N}"
    exit 0
fi

# ── 7. 复制脚本（排除 aim-upgrade.sh 自身） ──
COUNT=0
for s in "$SOURCE"/aim-*.sh; do
    [ -f "$s" ] || continue
    NAME=$(basename "$s")
    [ "$NAME" = "aim-upgrade.sh" ] && continue
    cp "$s" "$AIM/bin/$NAME" && chmod +x "$AIM/bin/$NAME"
    echo -e "  ${G}✓${N} $NAME"
    COUNT=$((COUNT + 1))
done
if [ -f "$SOURCE/aim_loader.py" ]; then
    cp "$SOURCE/aim_loader.py" "$AIM/bin/aim_loader.py"
    echo -e "  ${G}✓${N} aim_loader.py"
fi

# ── 8. 检测已移除的脚本 ──
for s in "$AIM/bin"/aim-*.sh; do
    [ -f "$s" ] || continue
    NAME=$(basename "$s")
    if [ ! -f "$SOURCE/$NAME" ]; then
        echo -e "  ${Y}⚠️  $NAME 在 source 中已不存在（未删除）${N}"
    fi
done

# ── 9. 更新 .aim-meta ──
cat > "$META" << EOF
version=$AVAILABLE
source=$SOURCE
installed=$(date +%Y-%m-%d)
EOF

# ── 10. 摘要 ──
echo ""
if [ "$INSTALLED" != "$AVAILABLE" ]; then
    echo -e "${G}✅ AIM 升级完成: v$INSTALLED → v$AVAILABLE${N}"
else
    echo -e "${G}✅ AIM 脚本已强制更新 (v$AVAILABLE)${N}"
fi
echo -e "   脚本: $COUNT 个已更新"
