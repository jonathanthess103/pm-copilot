---
name: consolidate
description: A reflective cleanup pass over your memory files (no external fetch). Merges duplicates, retires stale entries, sharpens durable facts, fixes the index so a future session orients fast, and proposes pruning, archiving, or splitting files that have grown too large. Backs up first, proposes changes, writes only on your yes. Triggers on "consolidate my memory", "clean up my memory". Run it right after sync, or whenever your memory needs a cleanup.
---

# Consolidate - Memory Hygiene (safe mode)

A reflective pass over what the co-pilot has learned about the user and their work. Goal: a future session should orient quickly (who they work with, what they're focused on, how they like things done) without re-asking. This reads and restructures the memory folder only; it does not fetch from external tools (that's `sync`, which normally runs just before this).

Memory lives in the `memory/` folder next to CLAUDE.md.

## Step 0 - Back up first (non-negotiable)
Snapshot the memory folder before any edit, same pattern as `sync`. If the backup fails, STOP.

## Phase 1 - Take stock
- List the memory folder and read the index in CLAUDE.md's routing table.
- Skim each file. Note which overlap, which look stale, which are thin.
- **Measure.** Record KB for every file in `memory/` and for CLAUDE.md, excluding `memory/state/` (audit and state logs are out of scope for pruning). Compare against the previous backup if one exists, and list files that only grew (additions, no removals).
- **Assign a tier.** Always-loaded (CLAUDE.md, injected in full every session) or routed (loaded when the routing table matches). Context cost is highest for always-loaded files, so review them first.

## Phase 2 - Plan the consolidation (propose-only)
Separate the durable from the dated:
- **Durable** (preferences, working style, key relationships, recurring workflows, standing initiatives): keep and sharpen.
- **Dated** (a finished project, a passed deadline, a one-off): retire the file, or fold the lasting takeaway (for example "prefers X format for launch docs") into a durable file, then drop the rest.

Prepare specific proposed changes:
- Merge duplicate facts into one canonical location.
- Fix anything stale or contradicted (prefer the newest confirmed fact; flag genuine conflicts for the user rather than guessing).
- Tighten wording so each file is scannable.
- Update the routing table in CLAUDE.md if files were added, merged, or retired.

### Prune and nest
Run this scan on every pass, whatever the file sizes. Growth is managed continuously, not only after a ceiling is hit.
- **Every run:** for each file outside `memory/state/`, list up to 3 candidates: entries that are dated, resolved, or restated elsewhere, and blocks that apply to one task type only. Skip a file with no candidates.
- **Approaching (over ~14 KB, or an always-loaded file that grew since the last run):** also report size and growth, and propose at least one prune or nest in that file now.
- **Over ceiling (~17.5 KB):** full pass over the whole file. Propose enough prunes and nests to bring it under the ceiling, or say what blocks that.

For each candidate, propose one of:
- **Prune:** move the entry to `memory/_archive/<file>/<file>-<YYYY-MM>.md`. Archive files are never in the routing table and are not loaded unless asked for.
- **Nest:** move a coherent block (for example one audience's rules from `voice.md`, or one workflow's rules from `day-to-day.md`) into a child file under `memory/<parent>/<name>.md`. Leave a pointer line in the parent that says what the child contains and when to load it. If CLAUDE.md is the parent, add the pointer to its routing table.
- **Slim CLAUDE.md:** replace any rule that applies to only one task type with a pointer to the file that holds it. CLAUDE.md keeps only rules that apply to every session.
- **Trim in place:** shorten wording without moving it.

Each proposal shows the file, its current size, what moves where, and the pointer line left behind. List always-loaded files first.

Present the plan as a short list: merge / retire / rewrite / reindex / prune / nest, one line each.

## Phase 3 - Apply only what's confirmed
Apply the approved changes. Add a dated changelog line to each affected file; for a prune or nest, the line names where the content went. Keep the backup. Confirm what changed in this session.

## Guardrails
- Propose-only. No write without the user's yes.
- Pruning means archiving, never deleting. Never delete a file outright; retire by folding forward the durable takeaway first.
- When two facts conflict and you can't tell which is current, ask; do not silently pick one.
