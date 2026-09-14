---
name: self-improvement
description: The weekly loop where the system learns from its own use. Scans your recent activity for drafts that got reworded (voice signals) and for repeatable workflows worth turning into skills or fixes, then applies the changes you approve. Walked through part by part, writes held to the end. Run it in a new chat whenever you want.
---

## GUIDED DELIVERY - one part at a time (always)
Do not output a single combined digest. Walk the user through the run part by part as separate turns in the OUTPUT order (Voice corrections, New skill candidates, Improvement candidates, Ready-to-apply diffs), each led by one plain intro line and ending with its question, then stop and wait. Hold all writes to the end and apply only what the user approves.

## FORMATTING - lists, never paragraphs (always)
Whenever you present more than one item, render them as a bulleted or numbered list, one item per line. Never pack multiple items into a run-on paragraph.

---

You are running the user's **self-improvement** pass, the weekly loop where the system learns from its own use. Read `memory/role.md` and `memory/day-to-day.md` first for tools, timezone, and work week. Surface everything in this session; never message the user externally. No em-dashes. Each phase is fault-isolated: if one errors, note it and continue. Signal-gathering (Phases 1 and 2) runs before applying (Phase 3) so the applier sees this week's new entries.

Friction log: `memory/skill-improvements.md`. Entry format: `- YYYY-MM-DD | "<quote or diff summary>" | proposed change in one line | open`.

## PHASE 1 - Draft-vs-sent scan (voice-correction signals)
Two inputs, then one dedup gate. Do not skip 1B because 1A found something.

**1A. Auto-scan.** Window: last 7 days. Scan in parallel, using the connected tools: recent session transcripts, chat sent by the user, email sent by the user, recent doc edits. For each draft the co-pilot produced (a message, email, doc section, ticket comment; ignore code and scaffolds), find what actually landed and classify: NEVER SENT (no match); SENT MATCHING (high overlap, skip); SENT DIVERGED (partial overlap, same intent, different wording, a voice-correction signal). If transcripts are unavailable, degrade to sent-only mode and say so.

**1B. Voice queue.** Read the queue file at the location named under "Voice queue" in `memory/day-to-day.md`. If no location is named there, skip 1B and say so. Take every row in its **Pending** section, whatever its age: the user flagged these by hand precisely because they edited the draft before sending, so they are pre-classified SENT DIVERGED and they do not expire out of the 7-day window.

**Dedup gate.** Key every candidate from both inputs on a stable artifact id (email thread id, chat channel plus message timestamp, file path). Drop any candidate whose key already appears in the queue file's **Reviewed** section. This is what stops an artifact reviewed in an earlier run coming back while the window still covers it.

For each surviving diverged draft, diff it line by line against what was sent and extract concrete edit patterns (word choice, structure, cuts), not generic notes. Separate the user's style from the co-pilot's own mistakes: durable style goes to the voice file, while a rule or fact that already existed in memory and was not applied goes to the friction log under a voice heading. Propose everything; do not auto-write.

**Close the loop.** Once the user has decided on an item, move its row from **Pending** to **Reviewed** in the queue file, with the date reviewed and where its output landed. Never delete a Reviewed row; that list is the dedup key. Add a Reviewed row for any 1A item the user reviewed as well, so it cannot resurface.

## PHASE 2 - Skill-spotter scan (new and improved skill candidates)
Scan the last 7 days across the connected tools for: (A) new skill candidates, repeatable workflows the user did 2+ times, asked for repeatedly, or that took multiple manual steps; (B) improvement candidates, friction with existing skills or tasks (corrections, redos, "why does it keep" moments). For each: name, where spotted, what it does today, the opportunity. Write (B) as proposed friction-log entries (propose-only). Frame as opportunity. Three sharp candidates beat seven vague ones.

## PHASE 2.5 - Memory gap sweep + triage
Invoke `memory-keeper` in weekly-sweep mode: read `memory/context-watchlist.md`, check each source for material change since it was last swept, and append genuine, routing-mapped gaps to the pending queue in `memory/context-gaps.md` (with dedup and relevance rules). Advance the "last swept" marker only for sources that succeeded. Then present the pending queue for triage, one line per item, drift first, with actions Ingest / Skip / Mute / Link. On Ingest, propose the memory diff (target file, target section, a short before/after) and write only on approval, then move the item to the ingested log. Skip increments a surface count and ages out to Muted after a few passes. Mute means never surface again. Propose-only.

## PHASE 3 - Apply approved diffs
Read every `open` entry in `memory/skill-improvements.md`, including any just proposed and approved this run. For each, propose a concrete diff to the target skill, task, or routing brain. Surface all diffs for bulk approve/reject. On approval, apply the change and flip the entry to `applied` (or `wontfix`), with a dated changelog line in the affected file.

**Drafted scores are never final.** When a project, build or improvement is written into the user's own prioritization system with priority scores the co-pilot drafted rather than the user set, say so on the row and end the run by naming every row that still needs their review. Use whatever "reviewed by the user" flag that system carries; if it has none, propose adding one before writing. Never leave a co-pilot-drafted score sitting in the user's store indistinguishable from one they set themselves: the store then ranks on numbers they never agreed to, and the ranking looks like their judgement. Leaving the scores blank is not the alternative, because an unscored row sorts to the bottom and goes unseen.

Also run the **weekly memory consolidation** step here if it is not scheduled separately: a reflective pass over the memory files to merge duplicates, retire stale entries, and fix the index. Propose the changes; write only on approval. (If the user set up the biweekly memory-refresh task, consolidation lives there instead; skip it here.)

## OUTPUT - walked through one part at a time
```
Self-Improvement - [date]
Draft-not-sent [ok/failed] · Skill-spotter [ok/failed] · Memory sweep [ok/failed] · Applier [ok/failed]

Voice corrections (drafts that diverged / never sent)
- [item] - [the divergence] - propose logging?

New skill candidates
- [name] - [what it'd automate] - build?

Improvement candidates (existing skills)
- [skill] - [the friction] - propose fix?

Ready-to-apply diffs (from open friction-log entries)
- [skill] - [one-line diff] - apply?

Rows needing your score review (drafted by me, not yet yours)
- [row] - [the scores I drafted] - correct them and tick the reviewed flag
```
Wait for approval on each part, then apply approvals and update statuses. Nothing written or applied without explicit confirmation this run. If the morning brief keeps an auto-close audit log, read its reopen records and report the auto-close false-positive rate so the accepted fuzzy-match risk stays measured.
