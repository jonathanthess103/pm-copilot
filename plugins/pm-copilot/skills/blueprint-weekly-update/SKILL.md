---
name: blueprint-weekly-update
description: Drafts the weekly management update for one deal's internal win channel (Status, Path to close, Risk, Help needed) from the deal's Blueprint, as text in chat to copy into Slack. Use when the user says "give me the weekly Slack update for <deal>", "the weekly win channel update for <deal>", "weekly update for <deal>" or "management update for <deal>". Not for post-call recaps, which go to quick-win-channel-update. Read-only: never posts, saves or writes anywhere.
---

# Blueprint Weekly Update

**Purpose:** draft the weekly management update for one deal, from its Blueprint, in the format of the user's template. Output is text in chat. The skill writes nothing and posts nothing.

**Triggers:** "give me the weekly Slack update for <deal>", "the weekly win channel update for <deal>", "weekly update for <deal>", "management update for <deal>". A post-call recap ("win channel update after the call", "share the recap with the team") belongs to `quick-win-channel-update`, not this skill. This skill does not check whether the deal is due this week: the cadence is in the template file and the user decides.

**Inputs:** the deal (account name, opp short name or SFDC opp name).

**Steps**

| # | Step |
|---|---|
| 1 | Read the Blueprint with `blueprint-read` (current mode). No ledger row: stop, say the deal has no Blueprint, and do not draft from other sources. Carry its checks into the flags: template older than the newest, Queued above 0, last updated more than 14 days ago (the draft is only as current as the Blueprint) |
| 2 | Load `memory/voice/win-channel-update.md`: the template (four parts, status definitions, cadence note) and the examples (layout). Missing: stop and say the template file is missing; do not draft from memory |
| 3 | **Status.** The RAG is the newest RAG call in `Judgment.md`, worded as the template defines it. None found: ask "What is the RAG for <deal>? Green (on track), Yellow (at risk) or Red (blocked or stalled)?" and wait. Never infer a RAG. Not green: add a short narrative from his Judgment words and the Blueprint facts. Close date, forecast category and amount: give the SFDC value labelled as SFDC, and his internal read only where he stated it |
| 4 | **Path to close.** The remaining steps in order, with owners, from Buying and Paper Process (section 8), open Customer Commitments (12), Timeline (14), and People and Zip team for owners. Early in a long cycle, give key next steps instead, as the template allows. An item labelled `(inferred)` or `GAP:` is not stated as fact: it goes to "Needs your input" |
| 5 | **Risk.** Each open risk (section 13), with what is being done about it where the Blueprint or Judgment says. Where nothing is recorded about what is being done, put it in "Needs your input". Write "None" only if there is no open risk |
| 6 | **Help needed.** Ask one question: "Anything blocked on someone outside the deal team?" Wait. Put his answer in the draft as he gives it. If it names someone outside the deal team, add to the flags that the template says the AE schedules a deal huddle with them |
| 7 | Build the draft in the layout below |
| 8 | Run `blueprint-voice` (type `slack-win-channel`) on the draft. It fixes wording. A structural mismatch it reports is fixed here, since this skill owns the structure |
| 9 | Deliver as described under Delivery |

**Rules while drafting**
- `Judgment.md` wins. Where it disagrees with a Blueprint fact, use his read and say so in the trace.
- Draw only from Judgment's Most important, Take at face value / not and Other sections and its Internal read table. Never use Private and game theory unless the user asks.
- Keep `(his read)` wording as his read. Never turn an `(inferred)` item into a stated fact.
- Every statement in the draft traces to a cite in the Blueprint or Judgment, or to the user's answer in this session.

**Layout** (from the template and the user's examples)

```text
<Account> <opp type> Update <M/D/YY>
<RAG emoji> <Green (On track) | Yellow (At risk) | Red (Blocked or stalled)> - <one-line call, plus a short narrative if not green>

1. Path to Close -
• <step, owner>
• <step, owner>

2. Risk -
• <named risk, and what is being done about it>

3. Help Needed - <his answer, or "None outside core deal team">
```

- The RAG emoji is the unicode circle (green, yellow or red), as in the template.
- Plain text. No bold, no @-mentions, no citations in the text.
- No em-dashes. Use a hyphen with spaces where the examples show a dash.
- Bullets use `•`. A customer's own words go in double quotes.
- No word cap: the template sets none. Write what the four parts need.

**Delivery** (chat only)
1. The draft in one block, ready to paste.
2. A trace table below it: each draft line, and its cite as stored (`[file Lx]`), or "your answer this session".
3. Needs your input: every `(inferred)` or `GAP:` item the draft left out, and anything the Blueprint did not hold.
4. Flags: the Blueprint checks from step 1, and the deal-huddle note from step 6 where it applies.
5. The closing line from `${CLAUDE_PLUGIN_ROOT}/references/closing-line.md`, as `Read: [files]. Not read: [files].` This skill saves nothing, so there is no Saved part.

**Never:** posts, drafts or schedules anything in Slack; writes any file; writes to Tactical or SFDC; infers a RAG; states an `(inferred)` or `GAP:` item as fact; puts a citation or lint output inside the draft text; changes a customer's quoted words.

**When something can't be reached**

| Situation | Behavior |
|---|---|
| No ledger row | Stop. Say the deal has no Blueprint |
| `memory/voice/win-channel-update.md` missing | Stop. Say the template file is missing |
| Judgment has no RAG call | Ask once (step 3) |
| Blueprint more than 14 days old | Draft anyway, and put the flag first in the flags |
| `blueprint-voice` cannot run | Say the check was not run, and show the draft |
