#!/bin/bash
# Z.AI agent dispatch — runs claude -p with Z.AI backend
# Usage: zai-dispatch.sh "prompt" [cwd]
#
# Requires: ZAI_API_KEY env var
# Optional: ZAI_MODEL (default: GLM-5)

set -euo pipefail

if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "ERROR: ZAI_API_KEY not set. Get one at https://open.z.ai" >&2
    exit 1
fi

PROMPT="${1:?Usage: zai-dispatch.sh \"prompt\" [cwd]}"
CWD="${2:-$(pwd)}"
MODEL="${ZAI_MODEL:-GLM-5}"

ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY" \
CLAUDE_MODEL="$MODEL" \
exec claude -p "$PROMPT" --cwd "$CWD"
