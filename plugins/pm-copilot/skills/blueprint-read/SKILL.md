---
name: blueprint-read
description: Read one opportunity's deal Blueprint correctly - router first, Judgment.md always, then Blueprint.md - in one of three modes (current state, what changed since a date, or a subagent dive into the raw source files). Read-only. Use when the user says "based on the blueprint", "what's the latest on <deal>", "what changed on <deal>", or "check the sources on <deal> for X", and whenever another Blueprint or output skill needs a deal's context.
---

# Blueprint Read

**Purpose:** read one opportunity's Blueprint correctly, for him or for another skill. Read-only. Writes nothing.

**Triggers**
- Invoked by Create, Update, Close out, New opp, Onboard, the weekly sweep, and any output skill
- His words: "based on the blueprint", "what's the latest on <deal>", "what changed on <deal>", "check the sources on <deal> for X"

**Inputs**

| Input | Required | Default |
|---|---|---|
| Deal (account name, opp short name or SFDC opp name) | Yes | |
| Mode: current / what changed / dive | No | current |
| Since (what changed mode) | No | 7 days ago |
| Question (dive mode) | Yes, for dive | |
| Named sources | No | If he named any, read only those (decision 3d) |

**Locating the deal**
1. Find the row in `memory/state/blueprint-ledger.md`: path, version, template version, status.
2. Several opps on one account: use the active one; read a closed one only when asked.
3. No row: say in one line that the deal has no Blueprint, then answer the usual way (win channel first, then Salesforce and Gong via Snowflake), unless another Blueprint skill called this one, in which case stop. Never search Drive for a substitute Blueprint.

**Read order, every mode**
1. `Router.md`: identifiers, links, source roadmap
2. `Judgment.md`: always read; it wins over every other source (3c)
3. `Blueprint.md`, following any `Blueprint/<section>.md` pointers for sections the request needs
4. Every mode, for the checks below: the Queued line of `Proposals.md`, and `${CLAUDE_PLUGIN_ROOT}/templates/blueprint/template-changelog.md`

**Modes**

| Mode | Also reads | Returns |
|---|---|---|
| Current | Nothing more | Current state, with citations as stored |
| What changed | `Changelog.md` entries since the date; roadmap rows since the date; `Proposals.md` | Changes by section (old → new), new sources, what's still waiting for approval |
| Dive | Source files chosen from the roadmap summaries for the question | Findings with `[file Lx]` citations. Each source is read by a subagent that returns only a cited digest, so long transcripts and win channels never land in the main context (decision 18) |

**Rules while reading**
- `Judgment.md` wins. Where it disagrees with a Blueprint fact, give his read and note the difference.
- Close date, forecast category, amount: give the SFDC value and his internal read, each labelled.
- Keep `(inferred)`, `GAP:` and suspected-competitor labels as stored. Never upgrade them in the retelling.
- Every fact passed on keeps its citation.
- Named sources (3d): read only those. If the request needs more, say which files and ask first.

**Checks reported, never acted on**
- Template version older than the newest in `${CLAUDE_PLUGIN_ROOT}/templates/blueprint/template-changelog.md`: say so and offer "update this"
- `Proposals.md` Queued above 0: say how many
- Last updated more than 14 days ago: say so

**When something can't be read**

| Situation | Behavior |
|---|---|
| Ledger row missing | No Blueprint: fall through to the usual answer (or stop, when called by another Blueprint skill) |
| Drive folder or file missing | Name the missing file, give what was readable, mark the rest unread |
| Source file named in the roadmap missing | Skip it, list it under "Not read" |

**Ends with:** `Read: [files]. Not read: [files].`
