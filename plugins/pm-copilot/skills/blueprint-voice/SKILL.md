---
name: blueprint-voice
description: Final check on anything a deal Blueprint skill writes before the user sees it or it is saved. Applies the user's voice rules for the audience, runs a deterministic lint for AI phrasing (banned words, antithesis and reversal tics, recap endings, throat-clearing, any em-dash), and for Blueprint entries checks that every statement carries a citation and uses only known labels. Called by Blueprint skills and by output skills that read from a Blueprint; not a rewrite-and-cut tool (that is the editor skill).
---

# Blueprint Voice

**Purpose:** clean a draft without changing its facts, citations, numbers, structure or length. Runs automatically; the user does not call it.

**Inputs:** the draft; output type (`email`, `slack-win-channel`, `slack-dm`, `doc`, `blueprint-entry`); audience; for `blueprint-entry`, the section each row belongs to.

**Steps**

| # | Step |
|---|---|
| 1 | Human-facing types: load `memory/voice.md` and check the draft against the Per audience bullet for this audience. Fix wording only; report a structural mismatch (order, layout, salutation) to the calling skill, which owns the draft's structure |
| 2 | Write the draft to a temp file and run the lint script below on it |
| 3 | `blueprint-entry`: put each section's table header and separator rows, copied from the file the rows will be written to (that deal's `Blueprint.md`, `Judgment.md` or `Changelog.md`), above that section's rows, then run the script with `--entry`. It checks the Cite cell of every row in a table whose header has a Cite column (Mantra, MEDDPICC and Discovery Gaps have none and are not citation-checked), that every bullet line ends in a `[<file> L<n>]` citation, and that every label is a known one |
| 4 | Any wording hit: rewrite once, keeping facts, citations and numbers, then re-run. Missing citation, unknown label and missing header hits are never rewritten: stop and show them. Still failing: stop and show the draft with `<<< HIT: <reason>` at the end of each failing line |
| 5 | Pass: return the clean draft. Lint output never appears in the deliverable |

**Never:** changes facts, citations or numbers while rewriting; changes quoted words (inside double quotes, straight or curly), which are the speaker's own; writes voice rules.

**When something can't be reached**

| Situation | Behavior |
|---|---|
| `memory/voice.md` missing | Lint still runs; the draft is marked "voice not applied" |
| Python not available | Apply the table by reading, and say the check was not run as code |

## Lint script

Run with `python3 -I - <draft-file> [--entry] <<'PY'` followed by this script and `PY`.

```python
import re, sys
path = sys.argv[1]; entry = "--entry" in sys.argv
text = open(path, encoding="utf-8").read()
# quoted words are the speaker's own: blank them (same length) so phrasing checks skip them
scan = re.sub(r'"[^"\n]*"|\u201c[^\u201d\n]*\u201d', lambda m: " " * len(m.group(0)), text)
I = re.I | re.M
checks = {
 "reversal cliffhanger": r"\b(wasn't|isn't|is not|was not)\s+(the|a|an)\s+\w+\.\s+(it|that|the)\s+\w+\s+(was|is)",
 "antithesis tic": r"it['’]?s not (just )?(\w+\s){0,2}\w+[,.;\s\-—]+\s*(it['’]?s|it is)\s+\w+",
 "AI vocab": r"\b(delve|leverage|robust|seamless|holistic|synergy|paradigm|empower|harness|streamline|cutting-edge|best-in-class|ecosystem|game-changer|unlock|elevate|disrupt|tapestry|landscape|notably|moreover|furthermore|utilize|underscore|pivotal|transcend|elucidate|illuminate|navigate|testament|realm|facilitate|foster)\b",
 "AI phrases": r"(here'?s the thing|the gap between|the quiet shift|this changes everything|a masterclass in|unlock your potential|stop doing|what if i told you|game changer|move the needle|double[- ]edged sword|let that sink in|but here'?s the kicker|let'?s unpack (this|that)|the future is here|read that again|harness the power of|the takeaway|at the end of the day|low[- ]hanging fruit|the bottom line|the hidden tax|make no mistake|dive deep into|in today'?s landscape|plot twist|elevate your game|buckle up|needle[- ]moving|best in class)",
 "throat-clearing": r"^[ \t]*(In today's|As we all know|It's no secret|In this article|Let me start by|Before we begin|It goes without saying)",
 "recap": r"\b(In summary|To recap|Let's review|Key takeaways|In conclusion|To sum up)\b",
 "filler transition": r"\b(Having said that|With that being said|That being said|Moving on to|Speaking of which)\b",
 "despite its challenges": r"\bDespite (its|these|the) (challenges|drawbacks|limitations)",
 "magic adverb": r"\b(quietly|fundamentally|deeply|remarkably|profoundly)\s+(transforms|changes|redefines|reveals|signals|matters)\b",
 "vague attribution": r"\b(industry reports|observers have|experts argue|studies suggest|some critics argue)\b",
 "em-dash": "—",
}
hits = []
for name, pat in checks.items():
    for m in re.finditer(pat, scan, I):
        line = scan.count("\n", 0, m.start()) + 1
        hits.append(f"L{line} {name}: {m.group(0)!r}")
if entry:
    one = r"\[[^\]\s]+\.md L\d+\]"  # also matches ../<prior-opp>/sources/<file>.md paths
    cites = re.compile(rf"^{one}(;\s*{one})*$")
    labels = re.compile(r"\b[A-Z]+:")
    known = {"GAP:", "CONFLICT:"}
    rows = text.splitlines()
    cells = lambda l: [c.strip() for c in l.strip().strip("|").split("|")]
    sep = lambda l: bool(l.strip()) and set(l.strip()) <= set("|-: ")
    cite_col = None; header_seen = False
    for n, l in enumerate(rows, 1):
        s = l.strip()
        if not s or s.startswith(("#", "<!--")) or sep(s):
            continue
        for lab in labels.findall(scan.splitlines()[n - 1]):
            if lab not in known:
                hits.append(f"L{n} unknown label: {lab}")
        if s.startswith("|"):
            if n < len(rows) and sep(rows[n]):  # header row: the template decides whether this table cites
                c = cells(s); header_seen = True
                cite_col = c.index("Cite") if "Cite" in c else None
                continue
            if not header_seen:
                hits.append(f"L{n} no table header: pass the section's header and separator rows with the entry")
                header_seen = True; continue
            if cite_col is not None:
                c = cells(s)
                if cite_col >= len(c) or not cites.match(c[cite_col]):
                    hits.append(f"L{n} missing citation: {s[:60]!r}")
        elif not re.search(one + r"\s*$", s):
            hits.append(f"L{n} missing citation: {s[:60]!r}")
print("PASS" if not hits else "\n".join(hits))
sys.exit(1 if hits else 0)
```

The script checks capitalised labels (`WORD:`) against `GAP:` and `CONFLICT:`. The other markers, `(inferred)`, `(suggested)`, `(prior opp)` and the Competition basis values `confirmed` / `suspected`, are checked by reading, since parentheses also appear in ordinary text.
