# Agents in Blueprint skills

## Rules for any agent

Every Blueprint skill that starts an agent follows these rules.

| Rule | |
|---|---|
| Say the cost first | Before any agent starts, say in one message how many agents, how many items each, roughly how many tokens, and what the agent adds that I don't already have. Start it only after your yes |
| Read-only only | An agent may not have any tool that sends, creates, updates or deletes in an outside system (Gmail, Slack, Notion, Snowflake, Salesforce, Drive). The one local write allowed is a fetch agent saving files into the deal's `sources/_staged/` folder; that limit is in the agent's own instructions, not enforced by its tool list. Every other write is made by the main session |
| Which agent | Reading a source file: `pm-copilot:blueprint-fact-pull`, per "Calling the fact-pull agent" below. Fetching from a connector: that connector's own fetch agent, one per connector, kept in the user's own agents folder, not in the fork. Gmail: `blueprint-fetch-gmail`, per "Calling the Gmail fetch agent" below. Slack, Notion and Snowflake: none exists yet, so a pull over the bulk line stops here: I say so, give the cost, and ask you. A general-purpose agent is never the substitute |
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
