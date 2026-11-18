# Agents in Blueprint skills

## Rules for any agent

Every Blueprint skill that starts an agent follows these rules.

| Rule | |
|---|---|
| Say the cost first | Before any agent starts, say in one message how many agents, how many items each, roughly how many tokens, and what the agent adds that I don't already have. Start it only after your yes |
| Read-only only | An agent may not have any tool that sends, creates, updates or deletes in an outside system (Gmail, Slack, Notion, Salesforce, Drive). The Snowflake fetch agent is the one exception: its tool runs any SQL statement, so a tool list cannot make it read-only, and its limit to `SELECT` statements is in the agent's own instructions only. The one local write allowed is a fetch agent saving files into the deal's `sources/_staged/` folder; that limit is in the agent's own instructions, not enforced by its tool list. Every other write is made by the main session |
| Which agent | Reading a source file: `pm-copilot:blueprint-fact-pull`, per "Calling the fact-pull agent" below. Fetching from a connector: that connector's own fetch agent, one per connector, kept in the user's own agents folder, not in the fork. Gmail: `blueprint-fetch-gmail`, per "Calling the Gmail fetch agent" below. Slack (`win-channel`): `blueprint-fetch-slack`, per "Calling the Slack fetch agent" below. Slack (`dm`): not pulled by intake. DMs reach a Blueprint through morning-brief's DM scan (decision 16) or what you tell or paste in chat. Notion meeting notes (`internal-call`): `blueprint-fetch-notion`, per "Calling the Notion fetch agent" below. Snowflake, Gong calls (`external-call`): `blueprint-fetch-snowflake`, per "Calling the Snowflake fetch agent" below; the agent's limit to `SELECT` statements is in its instructions only (see "Read-only only"). A general-purpose agent is never the substitute |
| An agent stops partway | I name the items it did not read. Finishing them follows the same cost message and your yes, never a further agent started on my own |
| No workaround | Where an agent is not allowed, the main session does not pull the material itself instead. A bulk pull from Notion, Gmail, Slack or Snowflake never runs in the main session: I stop and ask you. Bulk means a pull that would create more than 5 source files (one email thread, one call, one internal note or one Slack date-range file each); a Gong call counts the same as any other file |

# Calling the fact-pull agent

How a Blueprint skill gets facts out of a source file. Used by `blueprint-update` step 4, `blueprint-onboard` step 5 and `blueprint-read` dive mode. `<plugin root>` below is the folder that holds this file's `references/` folder (`${CLAUDE_PLUGIN_ROOT}` is filled in only inside skill and agent files, not in this one). The agent itself is `<plugin root>/agents/blueprint-fact-pull.md`. Run these steps in the main session, for each source.

| # | Step |
|---|---|
| 1 | Call `pm-copilot:blueprint-fact-pull`, one per source file. Pass only `Mode:` (`sections` or `question`), `Source:` (the file's path), and either `Template: <plugin root>/templates/blueprint/Blueprint.md` (sections mode) or `Question:` (question mode). Several may run at once, at most 20 at a time |
| 2 | Check the return's first line, `Source: <file> \| Last line: L<n> "<words>"`: line n must be the file's last line and must start with those words |
| 3 | Before using any fact, open each line it cites (those lines only) and drop or fix a cite that doesn't support its fact |
| 4 | Agent not available: stop and say so; never use another kind of subagent instead. Output partial, not in the return format, or failing step 2: run it once more; still failing, stop and name the file |

# Calling the Gmail fetch agent

Used by `blueprint-intake` for `email` sources. The agent is `blueprint-fetch-gmail`. If it is not available, stop and say so; never use another kind of agent instead. `<plugin root>` is as in the section above. `<deal sources>` is the deal's `BLUEPRINT/<opp>/sources/` folder.

| # | Step |
|---|---|
| 1 | List: call the agent with `Mode: list`, `Query:` the customer domains and deal label from the router header (from the day after the mark when there is one), and `Upper limit:` when the caller gave one. It returns the threads found |
| 2 | Say the cost, per the rules above: the thread and message counts and how many agent calls step 3 makes. Wait for the yes |
| 3 | Save: call the agent with `Mode: save`, `Thread ids:`, the same `Upper limit:` and `Since:` (the mark's date) as step 1, `Staged folder:` `<deal sources>/_staged`, `Template: <plugin root>/templates/blueprint/source.md`, and `Captured date:` today's date. Up to 5 threads per call, at most 20 calls at a time |
| 4 | Check each return: its `Saved` count and its `Not saved` table. List `_staged` to confirm each saved file is there. Report every thread not saved and why; a thread not saved never moves the mark |
| 5 | The files stay in `_staged`. `blueprint-intake` step 4 says what happens next |

# Calling the Slack fetch agent

Used by `blueprint-intake` for `win-channel` sources. The agent is `blueprint-fetch-slack`. If it is not available, stop and say so; never use another kind of agent instead. `<plugin root>` and `<deal sources>` are as in the sections above.

| # | Step |
|---|---|
| 1 | Inputs. From the router header: Channel id and Channel label, both from the "Win channel ID" line as written there. Since: the Date and time of the newest `win-channel` row in the source roadmap, `YYYY-MM-DD HH:MM:SS`; with no `win-channel` row there is no Since, and the pull starts at the beginning of the channel. A row whose Date and time has no time is not a usable mark: stop and ask you for the time. Upper limit: the caller's, when it gave one |
| 2 | Slack timestamps. Run `TZ=America/Los_Angeles date -j -f "%Y-%m-%d %H:%M:%S" "<time>" +%s` for Since (this is Since ts) and for `<Upper limit> 23:59:59` (this is Latest ts) |
| 3 | List: call the agent with `Mode: list`, `Type: win-channel`, Channel id, Channel label, Since, Since ts, and the Upper limit and Latest ts when there is one. It returns the message counts by month, the number of threaded messages, and the newest message's time. No messages: say so and stop; the mark does not move |
| 4 | Say the cost, per the rules above: the message count, the threaded-message count (each one is an extra read), and how many agent calls step 5 makes. Wait for the yes |
| 5 | Save: call the agent with `Mode: save`, the same inputs, `Staged folder:` `<deal sources>/_staged`, `Template:` `<plugin root>/templates/blueprint/source.md`, and `Captured date:` today's date. One call saves one file for the whole range. If the agent returns "turn limit reached" or "a thread is too long", split the range at a day boundary into two, each with its own Since and Upper limit (the second Since is the first Upper limit's day at 23:59:59), say so, and run both after your yes |
| 6 | Check the return: its `Saved` count, its `Covered through` time and its `Not saved` table. List `_staged` to confirm the file is there. Report every range not saved and why; a range not saved never moves the mark |
| 7 | The file stays in `_staged`; `blueprint-intake` step 4 says what happens next. When intake adds the roadmap row for a file this agent saved, the row's Date and time is the return's Covered through time, `YYYY-MM-DD HH:MM:SS`, not the file's date. That time is the next pull's Since |

# Calling the Notion fetch agent

Used by `blueprint-intake` for `internal-call` sources from the meeting-notes database. The agent is `blueprint-fetch-notion`. If it is not available, stop and say so; never use another kind of agent instead. `<plugin root>` and `<deal sources>` are as in the sections above.

| # | Step |
|---|---|
| 1 | Inputs. Title words: the account folder's name from the router header, and any other word you give. A note whose title has none of them is not found. Since: the Date and time of the newest `internal-call` row in the source roadmap, taken as the end of that minute (`HH:MM:59`); with no `internal-call` row there is no Since. A row whose Date and time has no time is not a usable mark: stop and ask you for the time. Upper limit: the caller's, when it gave one |
| 2 | List: call the agent with `Mode: list`, Title words, Since, and the Upper limit when there is one. It returns each note's title, created time, Notion attendees and URL. If it says more than 50 matched, say so, narrow the range with Since and Upper limit, and list again |
| 3 | Choose from the list. I pick the notes that belong to the deal from their titles and attendees, and name the ones I am unsure about and ask you; I do not open a note to decide. Notion attendees list only people in the Notion workspace, so a list showing only company addresses does not show that a call was internal. Type is `internal-call` only for a note you confirm was internal; a note I cannot place, I ask you about |
| 4 | Say the cost, per the rules above: how many notes, and that each note's whole text, often tens of thousands of characters, passes through its agent once to be read and once to be written. Step 5 makes one agent call per note. Wait for the yes |
| 5 | Save: call the agent once per note, with `Mode: save`, `Type:`, `Notes:` the note as the list gave it (`<url> | <created time> | <attendee emails>`), `Staged folder:` `<deal sources>/_staged`, `Template:` `<plugin root>/templates/blueprint/source.md`, and `Captured date:` today's date. At most 20 calls at a time |
| 6 | Check each return: its `Saved` count, its `Flags` and its `Not saved` table. List `_staged` to confirm each saved file is there. Report every note not saved and why; a note not saved never moves the mark |
| 7 | The files stay in `_staged`; `blueprint-intake` step 4 says what happens next. When intake adds the roadmap row for a file this agent saved, the row's Date and time is the note's created time from the return, `YYYY-MM-DD HH:MM`, so the next pull's Since can read it |

# Calling the Snowflake fetch agent

Used by `blueprint-intake` for `external-call` sources from Gong via Snowflake (the third source in intake's `external-call` order, after a `.docx` and a pasted transcript). The agent is `blueprint-fetch-snowflake`. If it is not available, stop and say so; never use another kind of agent instead. `<plugin root>` and `<deal sources>` are as in the sections above.

| # | Step |
|---|---|
| 1 | Inputs. Opportunity ids: the router header's "SFDC opportunity ID", plus every id the "Prior opp on this account" line gives. Since: the Date and time of the newest `external-call` row in the source roadmap, `YYYY-MM-DD HH:MM:SS`; with no `external-call` row there is no Since. A row whose Date and time has no time: Since is `00:00:00` on that date, and step 3 drops the calls already in the roadmap. Upper limit: the caller's, when it gave one |
| 2 | List: call the agent with `Mode: list`, Opportunity ids, Since, and the Upper limit when there is one. It returns each call's conversation key, title, start time, transcript length, the Salesforce objects it is linked to, and its participants with Gong's side tag (`company`, `non_company`, `unclassified`). No calls: say so and stop; the mark does not move |
| 3 | Choose from the list. I drop every call that matches a source already in the roadmap or the deal folder (a `.docx` or a pasted transcript) by date and attendees, and every call you have said to omit. I pick the rest from their titles, linked objects and participants, and name the ones I am unsure about and ask you; I do not open a transcript to decide. A call with no transcript length has no transcript and is reported, not saved |
| 4 | Type. The Gong side tags are evidence, not the answer. A call with any `non_company` participant is `external-call`. A call whose participants are all `company` is `internal-call` only when you confirm it. A call with an `unclassified` participant, I ask you about. One Type per agent call, so calls of different Types go in separate calls |
| 5 | Say the cost, per the rules above: how many calls, and that each call's whole transcript, often tens of thousands of characters, passes through its agent once to be read and once to be written. Step 6 makes one agent call per 5 calls or fewer. Wait for the yes |
| 6 | Save: call the agent with `Mode: save`, `Type:`, `Conversation keys:` (up to 5), `Staged folder:` `<deal sources>/_staged`, `Template:` `<plugin root>/templates/blueprint/source.md`, and `Captured date:` today's date. At most 20 calls at a time |
| 7 | Check each return: its `Saved` count, its `Flags` and its `Not saved` table. List `_staged` to confirm each saved file is there. Report every call not saved and why; a call not saved never moves the mark |
| 8 | The files stay in `_staged`; `blueprint-intake` step 4 says what happens next. When intake adds the roadmap row for a file this agent saved, the row's Date and time is the call's start from the return, `YYYY-MM-DD HH:MM`, so the next pull's Since can read it |
