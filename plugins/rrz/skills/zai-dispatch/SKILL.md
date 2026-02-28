---
name: zai-dispatch
description: >
  Use when ZAI_API_KEY is set and you need to dispatch subagent work (implementation, audits, fixes)
  through Z.AI GLM-5 instead of Anthropic Sonnet. Drop-in replacement for Agent tool dispatching.
---

# Z.AI Dispatch

Route subagent work through Z.AI GLM-5 via `claude -p`. Anthropic subscription stays for orchestration (Opus), Z.AI handles worker tasks (GLM-5).

## Setup

```bash
export ZAI_API_KEY=your_key_here   # add to ~/.bashrc
# Optional:
export ZAI_MODEL=GLM-5             # default
```

## How It Works

```
Main session (Anthropic OAuth, Opus) — orchestrates
  └─ subagent work → zai-dispatch.sh → claude -p (Z.AI, GLM-5)
```

Instead of `Agent tool (model: sonnet)`, use:

```bash
Bash tool:
  command: ${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh "prompt" /opt/pytek
  run_in_background: true    # for parallel dispatch
```

## When to Use

This skill OVERRIDES the dispatch mechanism in these rr skills when `ZAI_API_KEY` is set:

| rr skill | What changes |
|----------|-------------|
| **rr:audit** | 6 auditors dispatched via zai-dispatch.sh instead of Agent tool |
| **rr:pre-merge-review** | Fix tasks dispatched via zai-dispatch.sh |
| **rr:executing-plans** | Implementation tasks via zai-dispatch.sh |
| **rr:subagent-driven-development** | Implementer subagents via zai-dispatch.sh |

## Dispatch Patterns

### Single task (sequential)

```bash
# Blocks until done, returns output
${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh \
  "Fix: N+1 query in app/models/call.py:42. Use joinedload() instead of lazy load." \
  /opt/pytek
```

### Multiple tasks (parallel)

```bash
# Dispatch each as background Bash, collect results
Bash(${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh "Task 1..." /opt/pytek, run_in_background: true)
Bash(${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh "Task 2..." /opt/pytek, run_in_background: true)
Bash(${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh "Task 3..." /opt/pytek, run_in_background: true)
# Wait for all, review results
```

### Audit agent dispatch

```bash
# Fletcher
${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh \
  "You are Fletcher, a brutally honest code reviewer. Review scope: [files]. Feature: [name]. Focus ONLY on scoped files." \
  /opt/pytek

# Javert
${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh \
  "You are Javert, a completeness auditor. Spec: [plans]. Implementation files: [files]. Check every requirement." \
  /opt/pytek
```

## Detection

At the START of any rr skill that dispatches subagents, check:

```bash
echo "${ZAI_API_KEY:-not_set}"
```

- **`not_set`** → use standard Agent tool (Anthropic Sonnet)
- **anything else** → use zai-dispatch.sh (Z.AI GLM-5)

## Cost Comparison

| Provider | Input $/M | Output $/M | Relative |
|----------|-----------|------------|----------|
| Anthropic Sonnet | $3.00 | $15.00 | 1x (baseline) |
| Z.AI GLM-5 | $1.00 | $3.20 | **~5x cheaper** |
| Z.AI Coding Plan Pro | $15/msc flat | — | **fixed cost** |

## Limitations

- **Latency**: Z.AI servers in China — expect 2-4x TTFT from Europe
- **No agent resume**: `claude -p` is one-shot, no Agent ID for resuming
- **No agent personality loading**: Agent system prompts must be included in the prompt text
- **File conflicts**: Don't dispatch parallel fixes to the SAME file — run those sequentially
- **Prompt size**: `claude -p` argument has shell limits — for very long prompts, pipe via stdin:
  ```bash
  echo "very long prompt..." | ZAI_API_KEY=$ZAI_API_KEY ${CLAUDE_PLUGIN_ROOT}/scripts/zai-dispatch.sh - /opt/pytek
  ```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `ZAI_API_KEY not set` | `export ZAI_API_KEY=xxx` in shell |
| Timeout | Increase `API_TIMEOUT_MS` or check Z.AI status |
| Auth error | Verify key at https://open.z.ai |
| Model not found | Check `ZAI_MODEL` — default is `GLM-5` |
| Slow responses | China latency — consider OpenRouter as proxy |
