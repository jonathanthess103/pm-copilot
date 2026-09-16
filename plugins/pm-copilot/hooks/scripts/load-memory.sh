#!/usr/bin/env bash
# PM Co-Pilot: SessionStart loader.
# Prints the routing brain (CLAUDE.md) inline so it is already in context, and
# lists which memory files exist without loading them, so Claude loads the right
# ones on demand per the CLAUDE.md routing table. It does NOT print all memory
# into context (that would bloat every session).

set -euo pipefail

# Find the workspace: the current working directory if it has a memory/ folder,
# else PM_COPILOT_HOME if set, else the conventional default location. This
# matters because the user's deal work happens in sibling directories (Drive
# mounts, Downloads, other repos), not inside the workspace itself, so sessions
# are rarely opened there.
#
# Env vars are NOT a reliable fallback on their own: Claude Code sessions do
# not consistently source ~/.zshrc or other shell profiles, so a var set only
# there may never reach the process this hook runs in. PM_COPILOT_HOME is kept
# as an optional override (for anyone using a non-default location, sourced
# from wherever they've made it visible to this process), but the default
# below does not depend on it.
DEFAULT_WORKSPACE="${HOME}/pm-copilot-workspace"

resolve_workspace() {
  if [ -d "./memory" ]; then
    (cd . && pwd)
    return
  fi
  if [ -n "${PM_COPILOT_HOME:-}" ] && [ -d "${PM_COPILOT_HOME}/memory" ]; then
    (cd "${PM_COPILOT_HOME}" && pwd)
    return
  fi
  if [ -d "${DEFAULT_WORKSPACE}/memory" ]; then
    (cd "${DEFAULT_WORKSPACE}" && pwd)
    return
  fi
}

WORKSPACE="$(resolve_workspace)"

if [ -z "$WORKSPACE" ]; then
  echo "PM Co-Pilot: no memory/ folder here, none at PM_COPILOT_HOME, and none at the default ${DEFAULT_WORKSPACE}. Run /pm-copilot:setup, or set PM_COPILOT_HOME to your workspace root."
  exit 0
fi

MEM="$WORKSPACE/memory"

# State the absolute path prominently: skills reference memory/... as a relative
# path, so this is what makes them resolve correctly from outside the workspace.
echo "PM Co-Pilot active. Workspace: $WORKSPACE"
echo "Resolve every memory/... reference against $MEM, not the current working directory."
echo

# Print the routing brain itself rather than a pointer to it.
#
# Why this changed [2026-09-16]: a pointer is an action Claude has to take
# before it counts, and that action got skipped for an entire session. The
# global ~/.claude/CLAUDE.md and the global MEMORY.md are both injected as
# CONTENT at session start and both describe the same person and the same job,
# so the context reads as sufficient and a one-line "go read this file" loses
# to it. Claude ran a full task on the global file alone and missed the voice
# rules, the pre-output checks and every memory file in this workspace.
#
# This is a live read of the file, not a copy: edit CLAUDE.md in the workspace
# and the next session picks it up. Nothing to keep in sync.
#
# The memory files stay on demand - they total ~132 KB against ~11 KB here, so
# printing them all would be a 12x hit on every session. But the routing brain
# is the one file that decides whether anything else gets loaded at all, so it
# ships inline. This removes the dependency rather than restating it.
if [ -f "$WORKSPACE/CLAUDE.md" ]; then
  echo "=== BEGIN PM CO-PILOT ROUTING BRAIN ($WORKSPACE/CLAUDE.md) ==="
  echo "This is the authoritative instruction set for this user's work, and it is"
  echo "ALREADY LOADED below - do not re-read the file. Where it conflicts with"
  echo "~/.claude/CLAUDE.md, this file wins. Before answering anything about his"
  echo "work, his colleagues, his deals, his goals or his writing, load the memory"
  echo "files named in its routing table. Those are NOT loaded yet."
  echo
  cat "$WORKSPACE/CLAUDE.md"
  echo
  echo "=== END PM CO-PILOT ROUTING BRAIN ==="
  echo
else
  echo "WARNING: no CLAUDE.md at $WORKSPACE. The routing brain is missing. Run /pm-copilot:setup."
fi

echo "Memory files that exist but are NOT loaded. Load per the routing table above:"
ls -1 "$MEM"/*.md 2>/dev/null | sed 's#^# - #' || echo " (none yet)"
if [ -d "$MEM/topics" ]; then
  echo "Topic files:"
  ls -1 "$MEM/topics"/*.md 2>/dev/null | sed 's#^#   - #' || true
fi
exit 0
