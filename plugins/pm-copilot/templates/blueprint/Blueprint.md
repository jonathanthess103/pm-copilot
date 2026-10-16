# Blueprint: {{account_name}} / {{opp_short_name}}

Current state of one opportunity. Read through the shared reading module; change only through the Update Blueprint skill. Every statement carries a citation.

## 1. Header

| Field | Value |
|---|---|
| Blueprint version | v0 |
| Template version | {{template_version}} |
| Last updated | {{YYYY-MM-DD}} |
| Router | [Router.md](Router.md) |

## Ownership map

Each fact type has one home. Other sections link to it ("see People: <name>") and never restate it.

| # | Section | Owns | Write mode |
|---|---|---|---|
| 1 | Header | Version, template version, last updated | Overwrite |
| 2 | Deal Snapshot | SFDC fields: stage, close date, forecast category, amount, products in scope, segment, Zip team | Overwrite changed fields |
| 3 | People | Every customer person: name, title, role tags, stance, last contact | Update in place |
| 4 | Account Context | Firmographics, initiatives, news, finance and procurement environment | Update in place; upgrade tag on confirmation |
| 5 | Mantra | Which PBOs, RCs, metrics and proof point are selected; the story | Overwrite on material change |
| 6 | Evidence Logs + Discovery Gaps | Attributable customer evidence; open discovery gaps | Append; close gap when evidence lands |
| 7 | MEDDPICC | Assessment per letter only (facts live in owning sections) | Overwrite assessment |
| 8 | Buying and Paper Process | Decision steps, timeline, approvals, paper items | Update every source; inferred entries labelled |
| 9 | Scope and Commercials | Product, technical, services scope and phasing; pricing and terms | Confirmed only |
| 10 | Competition | Incumbent, confirmed and suspected competitors, status, traps set | Update in place; suspected moves to confirmed when the customer says it |
| 11 | Tech Stack | ERP and adjacent systems, integrations | Update in place |
| 12 | Customer Commitments | What the customer owes | Add, then close |
| 13 | Risks | The one risk register | Add, then close |
| 14 | Timeline | Dated events | Append row |
| 15 | Partner Context | Partners involved | Update in place; may stay empty |
| 16 | Close-out | Outcome, close date, customer-stated reason, who won, re-engage trigger | Written once, at close-out |

**Not stored here (other homes):** open tasks (Tactical), his read (Judgment.md), version history (Changelog.md), pending proposals (Proposals.md).

**Write modes**

| Mode | Meaning |
|---|---|
| Overwrite | Replace the value; the old value goes to Changelog.md |
| Update in place | Edit the row; the old value goes to Changelog.md |
| Append | Add a row; never edit an old one |
| Add, then close | Add a row; close it by setting Status, never delete |

**Citation:** `[<source file> L<line>]` after each statement, e.g. `[2026-09-12_external-call_disco.md L142]`.

**Markers:** `GAP:` not yet discovered. `(inferred)` Claude's read between the lines, not stated by the customer. `(prior opp)` carried from the account's previous opportunity, cited by relative path, until a source on this opp confirms it.

## 2. Deal Snapshot

| Field | Value | Cite |
|---|---|---|
| Stage | | |
| Close date (SFDC, as entered) | | |
| Forecast category (SFDC, as entered) | | |
| Amount (SFDC, as entered) | | |
| Products in scope | | |
| Segment | | |
| Zip team | | |

Close date, forecast category and amount are the values as entered in SFDC, which he manages publicly. His internal read on each lives in Judgment.md. A gap between the two is not a conflict.

## 3. People

| Name | Title | Role tags | Stance | Last contact | Notes | Cite |
|---|---|---|---|---|---|---|
| | | | | | | |

Role tags: EB, Champion, Coach, Blocker, Influencer, User.

## 4. Account Context

| Area | Detail | Tag | Cite |
|---|---|---|---|
| Firmographics | | | |
| Strategic initiatives | | | |
| News | | | |
| Finance and procurement environment | | | |

Tag: `research` or `customer-confirmed`.

## 5. Mantra

Framework: see Router header. Persona: {{persona}}.

**Condensed (2 to 3 sentences):**

| Part | Content | Evidence |
|---|---|---|
| Before | | |
| Negative Consequence | | |
| After | | |
| PBOs | | |
| Required Capabilities | | |
| Metrics | | |
| How We Do It | | |
| How We Do It Better | | |
| Proof Point | | |

A metric Claude suggests (not customer-stated) is marked `(suggested)`.

## 6. Evidence Logs

Every log uses the same columns. Type is Stated, Observed or Confirmed.

### 6.1 Before

| ID | Date | Source (see People) | Quote or finding | Type | Cite |
|---|---|---|---|---|---|
| | | | | | |

### 6.2 Negative Consequence

Same columns as 6.1.

### 6.3 After

Same columns as 6.1.

### 6.4 PBOs

Same columns as 6.1.

### 6.5 Required Capabilities

Same columns as 6.1.

### 6.6 Metrics (customer-stated only)

Same columns as 6.1.

### 6.7 Discovery Gaps

| ID | Gap | Opened | Closed by (evidence ID) |
|---|---|---|---|
| | | | |

## 7. MEDDPICC

| Letter | Status | Last confirmed | Trend | Gap | Facts in |
|---|---|---|---|---|---|
| M Metrics | | | | | 6.6 |
| E Economic Buyer | | | | | 3 |
| D Decision Criteria | | | | | 6.5 |
| D Decision Process | | | | | 8 |
| P Paper Process | | | | | 8 |
| I Identify Pain | | | | | 6.1, 6.2 |
| C Champion | | | | | 3 |
| C Competition | | | | | 10 |

## 8. Buying and Paper Process

### Decision steps, timeline, approvals

| Step | Who (see People) | Target date | Confirmed / (inferred) | Cite |
|---|---|---|---|---|
| | | | | |

### Paper

| Item | Status | Owner | Date | Cite |
|---|---|---|---|---|
| Order Form | | | | |
| MSA | | | | |
| InfoSec | | | | |
| NDA | | | | |
| Procurement / legal intake | | | | |

## 9. Scope and Commercials (confirmed only)

| Area | Detail | Cite |
|---|---|---|
| Product scope | | |
| Technical scope | | |
| Services scope | | |
| Phasing | | |
| Pricing discussed | | |
| Terms agreed | | |

## 10. Competition

| Vendor | Basis (confirmed / suspected) | Position (incumbent / in evaluation / eliminated) | Status | Traps set | Cite |
|---|---|---|---|---|---|
| | | | | | |

Confirmed: the customer said it; cite the customer source. Suspected: his read, usually from the post-call interview or an internal call; cite that chat or internal-call source file.

## 11. Tech Stack

| System | Category | Integration notes | Cite |
|---|---|---|---|
| | | | |

## 12. Customer Commitments

| ID | Item | Owner (see People) | Due | Status (open / done / dropped) | Cite |
|---|---|---|---|---|---|
| | | | | | |

## 13. Risks

| ID | Risk | Opened | Status (open / closed) | Cite |
|---|---|---|---|---|
| | | | | |

## 14. Timeline

| Date | Event | Cite |
|---|---|---|
| | | |

## 15. Partner Context

| Partner | Role | Status | Cite |
|---|---|---|---|
| | | | |

None recorded.

## 16. Close-out

Empty until the opportunity closes. His own read on why goes to Judgment.md.

| Field | Value | Cite |
|---|---|---|
| Outcome (closed-won / closed-lost) | | |
| Closed on | | |
| Customer-stated reason | | |
| Who won (see Competition) | | |
| Re-engage trigger or date | | |
