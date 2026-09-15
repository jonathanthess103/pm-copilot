#!/usr/bin/env bash
# PM Co-Pilot: SessionStart pointer.
# Deliberately light. It does NOT cat all memory into context (that would bloat
# every session). It points Claude at the routing brain and lists which memory
# files exist, so Claude loads the right ones on demand per the CLAUDE.md routing table.

set -euo pipefail

# Find the workspace: the current working directory if it has a memory/ folder,
# else the root named by PM_COPILOT_HOME. This matters because the user's deal
# work happens in sibling directories (Drive mounts, Downloads, other repos),
# not inside the workspace itself, so sessions are rarely opened there.
resolve_workspace() {
  if [ -d "./memory" ]; then
    (cd . && pwd)
    return
  fi
  if [ -n "${PM_COPILOT_HOME:-}" ] && [ -d "${PM_COPILOT_HOME}/memory" ]; then
    (cd "${PM_COPILOT_HOME}" && pwd)
    return
  fi
}

WORKSPACE="$(resolve_workspace)"

if [ -z "$WORKSPACE" ]; then
  echo "PM Co-Pilot: no memory/ folder here, and PM_COPILOT_HOME is unset or has none. Run /pm-copilot:setup, or set PM_COPILOT_HOME to your workspace root."
  exit 0
fi

MEM="$WORKSPACE/memory"

# State the absolute path prominently: skills reference memory/... as a relative
# path, so this is what makes them resolve correctly from outside the workspace.
echo "PM Co-Pilot active. Workspace: $WORKSPACE"
echo "Read $WORKSPACE/CLAUDE.md, then load relevant memory files on demand per its routing table. Resolve every memory/... reference against $MEM, not the current working directory."
echo "Available memory files:"
ls -1 "$MEM"/*.md 2>/dev/null | sed 's#^# - #' || echo " (none yet)"
if [ -d "$MEM/topics" ]; then
  echo "Topic files:"
  ls -1 "$MEM/topics"/*.md 2>/dev/null | sed 's#^#   - #' || true
fi
exit 0
