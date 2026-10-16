# Template changelog: deal Blueprints

Versions of the master templates in this folder, newest first. The newest entry is the current version; Create Blueprint stamps it into a new Blueprint's header. "Update this" on an existing Blueprint applies every Migration step newer than that Blueprint's template version, in order, oldest first. Entries older than the oldest template version on any live ledger row may move to `_archive/`; nothing is deleted. Not copied into deal folders.

## v1 ({{date the first real Blueprint is created}})

**Files:** `Router.md`, `Judgment.md`, `Blueprint.md`, `Changelog.md`, `Proposals.md`, `source.md`

**What changed:** initial templates.

**Migration:** none (first version).

<!-- Entry format for later versions:

## v{{n}} ({{YYYY-MM-DD}})

**Files:** {{templates changed}}

**What changed:** {{section or field, old → new}}

**Migration:** {{steps "update this" applies to an existing Blueprint, or "none"}}

-->
