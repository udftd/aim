#!/bin/bash
# AIM — aim-search.sh <query> [project] [--type sessions|memory|decisions|modules]
AIM="${AI_MEMORY_ROOT:-$HOME/.ai-memory}"
Q="$1"; P=""; TYPE=""
shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do case $1 in --type) TYPE="$2"; shift 2;; *) P="$1"; shift;; esac; done

[ -z "$Q" ] && echo "用法: aim-search.sh <query> [project] [--type sessions|memory|decisions|modules]" && exit 1

SP="$AIM"; [ -n "$P" ] && SP="$AIM/projects/$P"
echo "🔍 \"$Q\" in $(basename "$SP")/"
echo ""

if command -v rg &>/dev/null; then
    case "$TYPE" in
        sessions)  rg -i --type md -g "*SESSION*" -g "archive/*" "$Q" "$SP" -C 1;;
        memory)    rg -i -g "MEMORY.md" -g "PATTERNS.md" "$Q" "$SP" -C 1;;
        decisions) rg -i -g "DECISIONS.md" "$Q" "$SP" -C 1;;
        modules)   rg -i --type md "$Q" "$SP/modules" -C 1;;
        *)         rg -i --type md "$Q" "$SP" -C 1;;
    esac
else
    grep -ri --include="*.md" "$Q" "$SP" -n -C 1
fi
