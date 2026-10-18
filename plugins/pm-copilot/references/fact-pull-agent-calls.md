# Calling the fact-pull agent

How a Blueprint skill gets facts out of a source file. Used by `blueprint-update` step 4, `blueprint-onboard` step 5 and `blueprint-read` dive mode. `<plugin root>` below is the folder that holds this file's `references/` folder (`${CLAUDE_PLUGIN_ROOT}` is filled in only inside skill and agent files, not in this one). The agent itself is `<plugin root>/agents/blueprint-fact-pull.md`. Run these steps in the main session, for each source.

| # | Step |
|---|---|
| 1 | Call `pm-copilot:blueprint-fact-pull`, one per source file. Pass only `Mode:` (`sections` or `question`), `Source:` (the file's path), and either `Template: <plugin root>/templates/blueprint/Blueprint.md` (sections mode) or `Question:` (question mode). Several may run at once, at most 20 at a time |
| 2 | Check the return's first line, `Source: <file> \| Last line: L<n> "<words>"`: line n must be the file's last line and must start with those words |
| 3 | Before using any fact, open each line it cites (those lines only) and drop or fix a cite that doesn't support its fact |
| 4 | Agent not available: stop and say so; never use another kind of subagent instead. Output partial, not in the return format, or failing step 2: run it once more; still failing, stop and name the file |
