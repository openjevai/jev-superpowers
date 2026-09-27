#!/usr/bin/env bash
set -euo pipefail

echo "⚡ Installing jev-superpowers..."

TARGET_DIR="${HOME}/.agents/skills"
mkdir -p "${TARGET_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy all skills
cp -r "${SCRIPT_DIR}/skills/"* "${TARGET_DIR}/"

echo "✔ Skills installed to ${TARGET_DIR}:"
ls -d "${TARGET_DIR}/jev-"*

# Check prerequisite binaries
echo ""
echo "🔍 Checking TypeSafe Jev tooling on PATH..."

check_tool() {
    local tool="$1"
    local install_cmd="$2"
    if [ $# -ge 3 ]; then
        local probe="$3"
        if $probe >/dev/null 2>&1; then
            echo "  ✔ $tool found"
        else
            echo "  ✘ $tool MISSING! Install via: $install_cmd"
            MISSING=$((MISSING + 1))
        fi
    elif command -v "$tool" >/dev/null 2>&1; then
        echo "  ✔ $tool found ($(command -v "$tool"))"
    else
        echo "  ✘ $tool MISSING! Install via: $install_cmd"
        MISSING=$((MISSING + 1))
    fi
}

MISSING=0
check_tool "jev-scout" "cargo install jev-scout"
check_tool "jev-axi" "npm install -g jev-axi"
check_tool "git-jev" "git jev install" "git jev --version"
check_tool "jev-guard" "npm install -g jev-guard"
check_tool "supercov" "npm install -g supercov"
check_tool "limpet" "git clone https://github.com/noplan-inc/limpet ~/limpet (or /plugin install limpet@limpet)" "[ -f \"$HOME/limpet/limpet.py\" ] || command -v limpet || (command -v claude >/dev/null 2>&1 && claude plugin list 2>/dev/null | grep -q limpet)"
check_tool "jev-seo" "cargo install jev-seo"

has_local=0
if [ -n "${TYPESAFE_BASE_URL:-}" ] || [ "${TYPESAFE_BACKEND:-}" = "laya" ]; then
    has_local=1
fi

# Provider selection: JEV_PROVIDER=openjev wins; else TypeSafe if TYPESAFE_API_KEY set; else OpenJEV if OPENJEV_API_KEY set
use_openjev=0
if [ "${JEV_PROVIDER:-}" = "openjev" ]; then
    use_openjev=1
elif [ -z "${TYPESAFE_API_KEY:-}" ] && [ -n "${OPENJEV_API_KEY:-}" ]; then
    use_openjev=1
fi

if [ "$use_openjev" -eq 1 ] && [ "$has_local" -eq 0 ]; then
    if [ -n "${OPENJEV_API_KEY:-}" ]; then
        echo "✔ OPENJEV_API_KEY is configured (OpenJEV gateway to Jev)."
    else
        echo ""
        echo "❌ JEV_PROVIDER=openjev but OPENJEV_API_KEY is not set."
        echo "  Get your free API key at: https://openjev.sh/dashboard"
        exit 1
    fi
elif [ -z "${TYPESAFE_API_KEY:-}" ] && [ "$has_local" -eq 0 ]; then
    echo ""
    echo "❌ Neither TYPESAFE_API_KEY nor OPENJEV_API_KEY nor local FOSS backend is configured."
    echo "  TypeSafe Cloud: Get your free API key at: https://console.typesafe.ai"
    echo "  OpenJEV Gateway: Get your free API key at: https://openjev.sh/dashboard"
    echo "  Local FOSS: Run Laya via 'python scripts/serve-laya.py' and export:"
    echo "    export TYPESAFE_BASE_URL=\"http://127.0.0.1:8000\""
    echo "    export TYPESAFE_API_KEY=\"local\""
    exit 1
elif [ "$has_local" -eq 1 ]; then
    echo "✔ Local FOSS System 1 backend configured (${TYPESAFE_BASE_URL:-http://127.0.0.1:8000} / Laya)."
    : "${JEV_LOCAL_KEY:=local}"
    : "${TYPESAFE_API_KEY:=$JEV_LOCAL_KEY}"
    export TYPESAFE_API_KEY
else
    echo "✔ TYPESAFE_API_KEY is configured."
fi

echo ""
if [ "$MISSING" -gt 0 ]; then
    echo "⚠️  Skills installed successfully, but ${MISSING} prerequisite tool(s) were not detected."
    echo "   Install the missing tools above to activate their respective Jev reflex gates."
else
    echo "✔ All TypeSafe Jev tools and environment variables verified!"
fi
echo "🚀 jev-superpowers ready! Use 'jev-using-superpowers' or 'jev-brainstorming' in your agent sessions."
