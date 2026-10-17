# Designing a new SQL language feature: Key joins — presenter guide

Andreas Karlsson and Joel Jacobson · PGConf.EU, Valencia · 20 October 2026

36 main slides, followed by 4 optional appendix slides. The supplied timings total 41.9 minutes before questions. Timings are rehearsal targets, not an automatic playback schedule.

The slide source is a standalone 16:9 LaTeX/TikZ document with no external assets. The four titles specifically requested by Joel are preserved verbatim. Historical syntax is labelled. Explanatory failure descriptions are not invented PostgreSQL error output.

## Evidence conventions

Contemporaneous papers and emails establish wording and syntax. The planning recording supplies personal experiences, anecdotes, the TAS acceptance report and the Mimer implementation report. These are distinguished in the notes. The archive does not yet contain official minutes for the October TAS meeting. No claim is made that the feature is already in a released PostgreSQL or published ISO edition.

The technical examples are teaching reconstructions based on the cited proposals. They are not predictions about every intermediate prototype. Unless a slide changes the assumption, foreign keys are enforced and non-deferrable, and the shown referencing columns are NOT NULL.

## Running order

| Slide | Title | Time | Elapsed |
|---:|---|---:|---:|
| 1 | Designing a new SQL language feature | 0:20 | 0:20 |
| 2 | Who are we? | 0:45 | 1:05 |
| 3 | What will this talk be about? | 1:00 | 2:05 |
| 4 | What are key joins? | 1:10 | 3:15 |
| 5 | Joel’s first idea | 1:10 | 4:25 |
| 6 | Feedback from mailinglist | 1:30 | 5:55 |
| 7 | Proposal from Vik | 1:10 | 7:05 |
| 8 | Syntax bikeshedding | 0:40 | 7:45 |
| 9 | Why does constraint names not work? | 1:15 | 9:00 |
| 10 | Alternative: column lists | 1:05 | 10:05 |
| 11 | Learning the standards process | 1:30 | 11:35 |
| 12 | Sidetrack: the MATCH predicate | 0:50 | 12:25 |
| 13 | Pitching it to the PostgreSQL community | 1:00 | 13:25 |
| 14 | New arrow syntax | 1:00 | 14:25 |
| 15 | Reactions from the community | 1:15 | 15:40 |
| 16 | Trying to get derived tables right | 1:20 | 17:00 |
| 17 | Two many sides multiply | 1:25 | 18:25 |
| 18 | GROUP BY can create the key we need | 1:25 | 19:50 |
| 19 | Restarting work with ISO | 1:10 | 21:00 |
| 20 | KEY is not a keyword! | 1:15 | 22:15 |
| 21 | Riga: meeting Arne Roland | 0:50 | 23:05 |
| 22 | FILTER (WHERE …) | 1:20 | 24:25 |
| 23 | Strong objections | 1:20 | 25:45 |
| 24 | Completing the patch | 1:20 | 27:05 |
| 25 | The breakthrough | 1:40 | 28:45 |
| 26 | The proof belongs to each join | 1:30 | 30:15 |
| 27 | Three conditions give a useful contract | 1:35 | 31:50 |
| 28 | The first patch to -hackers | 1:05 | 32:55 |
| 29 | Stockholm: two proposals, more collaborators | 1:30 | 34:25 |
| 30 | Standardese experts | 1:40 | 36:05 |
| 31 | The final syntax changes | 1:20 | 37:25 |
| 32 | Acceptance in Tashkent | 0:55 | 38:20 |
| 33 | From shorthand to a verified contract | 1:15 | 39:35 |
| 34 | What we would do differently | 1:15 | 40:50 |
| 35 | Implementations | 1:05 | 41:55 |
| 36 | Questions? | 0:00 | 41:55 |

## 1 / 36 — Designing a new SQL language feature

**On-screen context:** PGConf.EU · Valencia · 20 October 2026

Open with the outcome: WG3 agreed to accept the proposal in Tashkent. This talk is the story of how the feature changed, not a tutorial on every rule.
The recording identifies Joel and Andreas as the presenters. Use Joel Jacobson, the international spelling he uses in the PostgreSQL community.

**Source footer:** PGConf.EU 2026 · Designing a new SQL language feature: Key joins

## 2 / 36 — Who are we?

**On-screen context:** Application queries brought us here

Recording 00:00–01:25. Both of us have written and reviewed large SQL queries, stored procedures, layered CTEs and views. That is the practical reason we care. Keep personal introductions short; this is not a CV slide.

**Source footer:** Presenters’ account; PGConf.EU session listing

## 3 / 36 — What will this talk be about?

**On-screen context:** One idea, many revisions

Recording 01:27–06:17. Signal the promised story: proposals that did not work, community feedback, implementation and committee collaboration. Acceptance is the coauthors’ first-hand report of the TAS meeting, not a claim that a new ISO edition has already been published.
The prepared talk is timed separately in this guide; leave time for questions.

**Source footer:** 2021 mailing-list discussion; WG3 papers; presenters’ account of TAS

## 4 / 36 — What are key joins?

**On-screen context:** A familiar join, with a precise expectation

Recording 03:11–06:17. The column declaration shown is in employees; departments.dept_id is its primary key. Enforced, non-deferrable constraints are assumed. This ON join already has the behavior we call a key join. Later we show how FOR KEY asks the DBMS to prove it. Do not suggest that every ON join is a key join or that the feature proves the whole query correct.
Omit the tentative BEAVER percentages from the recording: they were explicitly awaiting verification.

**Source footer:** TAS-028R1, Concept and 7.10; example adapted to employees/departments

## 5 / 36 — Joel’s first idea

**On-screen context:** March · Inspired by Cypher

Recording 06:17–08:57. Joel saw Neo4j’s SQL/Cypher comparison and mistakenly assumed its arrows meant foreign-key references. That misunderstanding inspired the idea. This exact path-expression query is reproduced in the written background and 2021 thread. It was a convenience idea, with the presence of a foreign key as a check; it did not yet have today’s preservation contract.
Source: https://www.postgresql.org/message-id/flat/CAMsGm5eeDXFX7oA9H6hF0E%2BaZZP4D8nbChtt_3BSotGPLXshNQ%40mail.gmail.com

**Source footer:** pgsql-hackers, March 2021 · “Avoid JOINs by using path expressions to follow FKs”

## 6 / 36 — Feedback from mailinglist

**On-screen context:** The problems with implicit joins

Recording 08:57–10:42. Credit the actual argument correctly: Álvaro Herrera raised ambiguity after adding a foreign key; Tom Lane explained the dependency problem and the composite-key issue. Andrew Dunstan and Pavel Stehule objected to hiding joins. Pantelis Theodosiou discussed intermediate results and repeated paths.
Joel initially defended the idea by comparing it to USING/NATURAL. In retrospect, an existing awkward feature is not a good reason to add another. Keep this self-critical rather than dismissing the feedback.

**Source footer:** pgsql-hackers, March 2021 · Herrera, Lane, Dunstan, Stehule, Theodosiou

## 7 / 36 — Proposal from Vik

**On-screen context:** Keep the join explicit

Recording 10:42–13:02. Vik’s concrete alternative mattered more than his “terrible idea” opening. The WITH example is the historical suggestion, not final syntax. It also handles multi-column foreign keys. Andreas recalls this as the point where he became interested. Vik’s insistence on working with the SQL standard shaped the next step.
Quote and example reproduced in the supplied written history, from the original 2021 correspondence.

**Source footer:** Vik Fearing, pgsql-hackers, March 2021 · historical syntax

## 8 / 36 — Syntax bikeshedding

**On-screen context:** 2021–2022 · With Anders Granlund, the mailing list and Hacker News

Recording 13:02–14:36. Introduce Anders Granlund as an early coauthor. The keywords on screen are successive ideas, not an exhaustive chronological list and not all from a single paper. WITH is from Vik’s suggestion; FOREIGN KEY from the January 2022 draft; KEY FROM/TO appear in the submitted early papers. Avoid spending the talk arguing which keyword is prettiest.

**Source footer:** 2021 correspondence; January 2022 draft; UTC-107 / CMN-023

## 9 / 36 — Why does constraint names not work?

**On-screen context:** A declaration is not a column occurrence

Recording 14:36–15:55. Keep the user’s exact title. This teaching example uses two instances of employees, each carrying the same declared dept_id foreign key. A derived table is a query result, such as a view or subquery. The base constraint name alone cannot choose between employee_dept_id and manager_dept_id at this surface. One could design more syntax to resolve this, but a bare name is not enough. This is the specific repeated-base-table issue documented in POS-009 p.3.
Do not repeat the recording’s claim that ISO constraint names are globally unique; schema-wide naming is a separate nuisance and not the main argument.

**Source footer:** POS-009, p. 3 · illustrative view with two instances of employees

## 10 / 36 — Alternative: column lists

**On-screen context:** Identify the columns exposed by the query

Recording 15:55–16:28. Andreas recalls inspiration from PostgreSQL ON CONFLICT’s ability to identify a unique constraint by columns instead of name. This is an analogy about identifying a relationship; the key-join proof is more involved. The displayed historical syntax follows UTC-107 / CMN-023: the newly joined right table’s list comes first. Later slides will change this.
Constraint-name syntax was considered, not proved impossible in all conceivable designs.

**Source footer:** May 2022 SIS draft, p. 2; UTC-107 and CMN-023 · two explicit column lists

## 11 / 36 — Learning the standards process

**On-screen context:** From Sweden to WG3

Recording 16:28–19:15. Explain WG3 once: the working group responsible for SQL and related database languages. SIS is the Swedish national standards body. Keith Hare presented UTC-107 at Zeist; the next minutes say it was discussed. Joel and Anders then presented CMN-023 in Casablanca. Jörn and Karl saw practical value; Vik volunteered to help.
Do not state that nobody responded at UTC as an objective minutes finding. The coauthors’ experience was that the first presentation did not give them a clear next step. Source: W25-001 item 9.2.9; W26-001r1 item 9.2.3.

**Source footer:** UTC-107 → W25-001; CMN-023R3 → W26-001R1

## 12 / 36 — Sidetrack: the MATCH predicate

**On-screen context:** After Casablanca, before Athens · A shortcut that did not simplify the design

Recording 19:15–22:01. The MATCH predicate is distinct from a foreign key’s MATCH type. The idea was to build on it to simplify the change proposal, but it did not settle the intended null behavior. This was an internal exploration, not a released implementation. Ordinary equality does not match a null component. We return to the nullability breakthrough later. No need to teach MATCH PARTIAL here or claim no DBMS has ever implemented the predicate.

**Source footer:** Presenters’ design recollection · recording 19:15–22:01

## 13 / 36 — Pitching it to the PostgreSQL community

**On-screen context:** Athens · A prototype in the hallway

Recording 22:01–24:37 and 26:27–28:04. Describe the hallway-salesman anecdote briefly. First found prototype commit is 30 September 2024, followed by the October Athens conference. Base tables were a useful first implementation milestone; it was a mistake to think that this settled the feature’s scope. Query operands also include views, CTEs, subqueries and joined tables.

**Source footer:** Prototype history, September–October 2024; PGConf.EU Athens

## 14 / 36 — New arrow syntax

**On-screen context:** October · Fewer competing meanings for FROM

Recording 24:37–26:27. The old FROM keyword competed visually with the FROM clause. The 6 October 2024 patch changed KEY FROM/TO to arrows. At this stage the unqualified list refers to the newly joined right operand. Therefore the arrow in this historical example points left in the written specification even though the referencing table is the SQL join’s left operand. Do not silently present this as today’s syntax.
Source: 2024-10-06T23-38-32.100_00_0002-Use-arrow-syntax-and-for-Foreign-Key-Joins.patch.

**Source footer:** Prototype patch, 6 October 2024 · historical syntax

## 15 / 36 — Reactions from the community

**On-screen context:** Peter Geoghegan · Athens

Recording 26:27–28:04. This is a paraphrase, not a direct Peter quote. Joel’s email of 23 October 2024 thanks Peter for changing his view: one implementation accepting what another rejects would be a portability problem. Andreas also recalls changing his mind. We wanted a specified conservative proof, not arbitrary implementation guesses.
Primary correspondence: /Users/joel/Downloads/Foreign key joins.eml, Joel to Peter Geoghegan, 23 October 2024.

**Source footer:** Joel → Peter Geoghegan, 23 October 2024; presenters’ recollection

## 16 / 36 — Trying to get derived tables right

**On-screen context:** A foreign key is only the beginning

Recording 28:04–34:18. A derived operand is the result of a query: for example, a view, CTE or subquery. The result of an earlier join is also an operand. Assume order 1 has two payments, and some order references an inactive customer. The declared foreign keys still exist, but the first target is not unique and the second lacks coverage.
Early papers already attempted these derivations. The development here is making the rules precise, complete and implementable—not first discovering that derived tables exist. Contrast uniqueness with functional dependency if asked: duplicate identical target rows still multiply a SQL bag join.
Use current terminology to explain the challenge, not a claim of exact 2024 implementation behavior.

**Source footer:** CMN-023R3, derived-table discussion; TAS-028R1, uniqueness and coverage

## 17 / 36 — Two many sides multiply

**On-screen context:** The fan trap

Recording 59:46–01:00:56. This problem helped make the later validation-scope insight concrete. We introduce it here while describing the derived-table problem and return to the proof boundary in the breakthrough. Each real relationship has many rows on the other side. Their Cartesian combinations double both totals in this fixture. GROUP BY cannot repair prior multiplication.
With FOR KEY on both joins, the second join is rejected: its referenced o.id occurs twice in the left input. The first join can be valid because its referencing rows are the items; it does not promise one output per order. Do not claim that all aggregate bugs are detected or suggest SUM(DISTINCT amount) as a general fix.

**Source footer:** BMA-015R1, pp. 11–12 · illustrative amounts

## 18 / 36 — GROUP BY can create the key we need

**On-screen context:** Aggregate each many side before joining

Each order_id is NOT NULL REFERENCES orders(id); constraints are enforced and non-deferrable. GROUP BY establishes uniqueness of the derived totals by order_id. Each grouped row still refers to an order. The first join no longer duplicates o.id, so the second proof can succeed. Orders with no items/payments remain, with a null total on that side.
The support for derived uniqueness matters: a blanket prohibition on derived tables would reject this useful shape. The final syntax is deliberately used for teaching, not presented as 2024 grammar.
Source: BMA-015R1 p.12, normalized names/amounts; TAS-028R1 p.8.

**Source footer:** BMA-015R1, p. 12; TAS-028R1 · final syntax used for illustration

## 19 / 36 — Restarting work with ISO

**On-screen context:** Christmas 2024 into 2025 · Working with Vik and Jim

Recording 34:26–37:51. Joel visits Vik in France around Christmas 2024. Later Jim Melton helps with the proposal in Paris; do not date the Paris meeting to Christmas. This is a deliberate return to a narrow normative scope, despite the earlier work on derived-table algorithms. POS-009R1 and BCN-060 focus on base tables, while the broader design remains in discussion material.
Tell the “now this will surely pass” moment in your own words rather than manufacturing an English verbatim quotation.

**Source footer:** POS-009R1 / BCN-060; presenters’ account of work with Vik and Jim

## 20 / 36 — KEY is not a keyword!

**On-screen context:** Barcelona · PostgreSQL KEY is unreserved; FOR is reserved

Recording 37:51–40:53. Keep the exact title as requested, and immediately explain its deliberate shorthand: PostgreSQL does have a KEY token, but it is unreserved. FOR is reserved. Peter Eisentraut’s feedback forces the grammar issue into focus. Adding FOR avoids making KEY newly reserved and avoids ambiguity with existing identifier/alias uses.
The local src/include/parser/kwlist.h confirms the keyword categories. W30-001 records the BCN question about KEY; W30-020/R1 supplies the resulting FOR KEY form. Do not claim that KEY is not a keyword in any SQL implementation.

**Source footer:** BCN → W30 · PostgreSQL keyword categories; W30-020R1 grammar

## 21 / 36 — Riga: meeting Arne Roland

**On-screen context:** PGConf.EU · October

Recording 41:30–43:40. Joel meets Arne while Andreas is talking to him. Shared interests include serious application SQL, formal reasoning and correctness. Their first collaboration was SQL-query equivalence and theorem proving. The background dates the invitation to help with Key Joins to 12 March 2026. Avoid implying Arne wrote the 2024 prototype or joined the patch immediately in Riga. He is not expected in the Valencia audience.

**Source footer:** Presenters’ recollection; correspondence chronology in background notes

## 22 / 36 — FILTER (WHERE …)

**On-screen context:** A requested feature that we later removed

Recording 43:40–45:42. Karl Schendel asks for extra join conditions; Vik suggests FILTER (WHERE ...), recorded in the W30 minutes. The displayed syntax is the actual BMA stage (June 2026), with an illustrative active predicate. It is not current syntax.
BMA-015R1 already promises non-null enrichment on p.5 while retaining supplemental FILTER on pp.9–11 and SC AND FSC on p.43. This is an inconsistency in that stage, recognized later, not a conflict created only by a later promise. TAS-028 removed the supplemental clause; R1 explains why its role was confusing. Some users expected a predicate to help prove a key join; others expected it merely to restrict the ON condition. The PostgreSQL prototype can separately reason about some operand filter conjuncts; do not confuse those with the removed supplemental clause.
Source: GRU-001R1 item 9.4.5; BMA-015R1 pp.5,9–11,43; TAS-028R1 p.2.

**Source footer:** W30 request; BMA-015R1 syntax shown; supplemental FILTER removed in TAS

## 23 / 36 — Strong objections

**On-screen context:** W30 · Two response papers

Recording 45:38–48:04. A frank but document-based slide. The quotation is an excerpt from Michels, W30-028 §1.1 p.2; its sentence continues “by comprehensively testing the application.” Do not attribute it to Venzl. The response hurt, and it is fair for Joel to say so. The papers do not establish hidden corporate motives.
Some criticism was valuable: Venzl’s left/right-order and missing-name objection foreshadows the final syntax improvement. Michels challenged scope, constraints and checking. The W30 minutes assign collaboration between Jim/Joel/Vik and Peter/Gerald/Jan; they do not record a formal rejection. Keep this to the design lesson, not an extended personal dispute.
Sources: W30-027 pp.2–3; W30-028 §1.1 p.2; GRU-001R1 pp.9–10.

**Source footer:** W30-027, pp. 2–3; W30-028, §1.1, p. 2 · quotation is an excerpt

## 24 / 36 — Completing the patch

**On-screen context:** A deadline: the Stockholm meeting

Recording 48:04–53:18. Arne became central to making the implementation robust. Joel ported it to PGlite, launched the browser demo on 28 March 2026, and used coverage-oriented LLM review loops to generate cases. The goal included Modified Condition/Decision Coverage (MC/DC); do not claim a verified 100% result. Experienced developers still had to reason through the difficult fixes.
The public demo is https://keyjoin.org/. A demonstration is optional: use it if the network and browser are ready, not as a prerequisite for finishing the talk. The deck works offline.

**Source footer:** Presenters’ development history, March–May 2026 · keyjoin.org

## 25 / 36 — The breakthrough

**On-screen context:** April · Make the result guarantee explicit

Recording 53:18–01:05:40. Reading the cardinality-preserving-table ballot comment prompted a productive question: what does the join promise about its result? This was inspiration, not a proof that JOIN TO ONE’s subset wording was logically contradictory.
The team explored a separate NULLS control, then realized ordinary join types express the required preservation. If the referencing columns may be null, use an outer join preserving that operand. INNER remains perfectly legitimate SQL with ON; FOR KEY deliberately asks for a stronger promise. Show the LEFT version verbally or in the next conditions slide.
The team recalls settling these semantics around PGConf.DE in April 2026. Earlier drafts had nullability logic; the breakthrough was the clear result contract.

**Source footer:** BMA-015R1, pp. 5–6, 14–15; design recollection, April 2026

## 26 / 36 — The proof belongs to each join

**On-screen context:** The other half of the breakthrough: validation scope

Recording 59:00–01:01:40. Reuse the two-many-sides example. At join 2, the referenced operand is the whole orders/items result. Its o.id values are 1,1. A catalogue lookup on orders alone would miss the duplication. Wrapping that subtree in a view should not change the relevant proof obligation.
Derive facts at query surfaces, check the binary operator, then pass the result’s facts upward. The guarantee is local to this join. A later WHERE or join may still filter or multiply the result. An earlier outer join may null-extend even a base NOT NULL column.
This is a conceptual tree of the written query, not an execution-plan claim: optimizer reorderings must preserve semantics.

**Source footer:** BMA-015R1, pp. 11–12, 14–15; TAS-028R1, operand derivation

## 27 / 36 — Three conditions give a useful contract

**On-screen context:** The DBMS must prove them, or report an error

Recording 01:04:55–01:11:37. The declared FK supplies the relationship; these are the three mathematical obligations on the current operands. Together they give exactly one output occurrence for every incoming referencing row, plus the unique referenced row for every all-non-null reference. An outer join may also emit referenced-only rows, so do not equate this with equal total row counts for every join type.
Errors can explain which fact is missing: relationship, uniqueness, match existence, or null preservation. Avoid presenting E0–E3 as standardized codes. Rejection means the specified conservative proof did not succeed, not necessarily that every possible dataset violates the condition.
Mention the improved diagnostics and Christoph Berg’s enthusiastic reaction as a recollection; there is no need for a fabricated terminal screenshot.

**Source footer:** TAS-028R1, pp. 3–4, 7–9 · mathematical conditions on complete operands

## 28 / 36 — The first patch to -hackers

**On-screen context:** A working feature still has to be reviewable

Recording 01:12:58–01:14:27. The team gets the implementation out before the Stockholm meeting. Tomáš Vondra asks for the patch to be broken into smaller pieces. This is not just administrative cleanup: reviewers need to follow each change and verify its assumptions.
Do not give an exact first-posting date without the original message. The source notes record substantial test work in May. Contrast a complete working prototype with a patch series ready for core review.

**Source footer:** Presenters’ account of the first review and Tomáš Vondra’s feedback

## 29 / 36 — Stockholm: two proposals, more collaborators

**On-screen context:** BMA · June

Recording 01:14:40–01:22:19. Joel hosts the meeting; Andreas attends as a guest. The amended JOIN TO ONE proposal requires explicit INNER or LEFT. LEFT can preserve the left row count; INNER may filter unmatched rows. Neither requires that the selected columns follow a declared FK. Its runtime error on multiple matches and our compile-time proof are different mechanisms.
Do not repeat the background claim that any filtering contradicts the original cardinality-preserving-table comment: the quoted comment says “subset.” The BMA minutes record JTO acceptance and request that Key Joins be revised and brought back. Karl volunteers to help. Bengt engages as an implementer; Leonid asks about how restrictive the proof rules should be.
Sources: BMA-038R1 pp.2–4; W32-001R1 items 9.4.2 and 9.4.11.

**Source footer:** BMA-038R1; W32-001R1, minutes of BMA, pp. 11–14

## 30 / 36 — Standardese experts

**On-screen context:** A shared design effort, not just proofreading

Recording 01:22:20–01:30:04. Karl’s offer at Stockholm matters enormously. Work at the editors’ meeting in Åland, then with Jörn and Fred, improves the feature as well as the words. All six names appear among TAS-028R1’s coauthors alongside the original developers. Do not imply all held the same editorial office or add current employer claims.
The displayed sentence quotes the first sentence of TAS-028R1 p.5, proposed 7.10 SR4.1)a)iii). The term “simply contain” denotes a defined syntactic relationship. Likewise immediately, generally and broadly are technical modifiers, not ordinary conversational emphasis. The example illustrates why experienced standard authors matter.
W32 in August still did not accept the proposal. That is different from the October TAS outcome. The lesson is to collaborate with the relevant experts earlier, not send them a finished design to rubber-stamp.

**Source footer:** TAS-028R1, pp. 1, 5 (7.10 SR 4.1)a)iii)); presenters’ account

## 31 / 36 — The final syntax changes

**On-screen context:** Put the column lists in the order of the join operands

Recording 01:30:04–01:33:17. Peter Eisentraut kept pressing on the syntax. Gerald Venzl had also made related order/name objections in W30-027. Credit the useful criticism wherever it came from.
The arrow direction did not change its meaning: it still points from referencing to referenced columns. The two lists changed order, and both references became mandatory. This also resolves naming when either operand is itself a joined table. Both table references are chosen from names exposed by their corresponding complete operand.
The TAS work also repairs dependency handling, including SQL/PGQ interactions; do not say all the changes were cosmetic.

**Source footer:** W30-027, pp. 2–3; TAS-028R1, p. 2

## 32 / 36 — Acceptance in Tashkent

**On-screen context:** TAS · October

Recording 01:33:17–01:36:48. The presenters explicitly decided this should be a celebration slide. Their account is that the meeting reached consensus to accept the proposal, with wording cleanup still to follow. Keep the distinction between a WG3 decision, incorporation into an IWD, and a published ISO edition. No official TAS minutes are available in the archive snapshot; TAS-001R1 is the previous W32 meeting’s minutes, not this decision.
Do not replay the personal arguments from the meeting or claim the feature is already committed to PostgreSQL.

**Source footer:** Presenters’ first-hand account of the October 2026 TAS meeting

## 33 / 36 — From shorthand to a verified contract

**On-screen context:** What the feature became

TAS-028R1 defines a syntax transformation to the corresponding ON equality conjunction after verification. This reuses normal SQL join semantics and optimization; no second meaning of equality or null is introduced. The analysis must retain key-join identity for subsequent derivations, even though execution uses the equality condition. There is proof/dependency-maintenance cost, so do not claim zero overhead.
This closes the story’s opening contrast: convenience remains, but the value is the explicit requirement that the DBMS establish the author’s assumptions. Ordinary ON remains available when the intended join has different behavior.

**Source footer:** TAS-028R1, Syntax Rules for 7.10 · verified transformation to ON

## 34 / 36 — What we would do differently

**On-screen context:** Lessons from the journey

Recording 01:37:40–01:39:54. The main lesson is collaboration across organizations and disciplines. Standards experts are not merely copyeditors; their questions can expose missing design decisions. Implementations and examples reveal issues the prose misses. Most contributors worked alongside other responsibilities, so five elapsed years are not five years of full-time coding.
Tie back to one candid mistake: hiding joins, relying on constraint names alone, leaving derivations implementation-defined, or the extra FILTER clause. Avoid implying all criticism was good or every delay useful.

**Source footer:** Presenters’ retrospective

## 35 / 36 — Implementations

**On-screen context:** The next chapter is review and use

Recording 01:39:54–01:42:23. Thank Bengt Gunne. The presenters report a Mimer implementation in roughly three weeks; the sources do not establish a public released version, so do not print a release claim. PostgreSQL has a patch under review, not a committed core feature. The test corpus made independent implementation easier.
Public demo: https://keyjoin.org/
Current v15 posting supplied by Joel: https://www.postgresql.org/message-id/bd598b83-9371-4857-90e4-4d5ded4613b5%40malkut.net
Ask for concrete help: read the series, try realistic queries, question the proof rules and diagnostics.

**Source footer:** Presenters’ implementation report · PostgreSQL patch under review

## 36 / 36 — Questions?

**On-screen context:** Thank you

Stop the prepared talk here. Appendix slides follow for questions, not as extra scheduled content. The source and presenter notes are editable; the deck needs no network connection unless you choose to open the demo.

**Source footer:** PGConf.EU 2026 · Valencia

## A1 — One hotel hid the bug

**On-screen context:** Appendix · Composite foreign keys

A reservation references a room by (hotel_id,room_number). With one hotel, a join on room_number alone may happen to look right. A second hotel with the same room number produces extra matches. FOR KEY with the shorter lists cannot identify the declared composite FK. This catches a specific omitted-key-column mistake; it does not verify all application intent.
Source: BCN-060 pp.3–5; BMA-015R1 pp.15–16; the example already appears in the May 2022 paper. Do not date its invention to Athens.

**Source footer:** BCN-060, pp. 3–5; BMA-015R1, pp. 15–16

## A2 — A declaration is not a data guarantee

**On-screen context:** Appendix · NOT ENFORCED was a real design change

W30-030 pp.1–2 explicitly permits NOT ENFORCED/deferred constraints under the weaker relationship-checking goal. The 2026 preservation design changes that assumption. This is worth acknowledging as an actual semantic change, not merely an editorial clarification.
The final proof must not claim match existence from metadata that does not establish it. The relevant constraint requirements are in BMA-015R1 and TAS-028R1. Do not imply PostgreSQL currently supports SQL’s NOT ENFORCED FK spelling just because the standard discussion considered it.

**Source footer:** W30-030, pp. 1–2 → BMA-015R1 / TAS-028R1

## A3 — NOT NULL can be lost before the next join

**On-screen context:** Appendix · Null-extension is a property of the operand

Assume order_items.order_id and product_id are NOT NULL foreign keys to orders and products. The first LEFT key join is valid: every actual item matches its order, and orders without items can produce extra referenced-only rows. Its result contains a null-extended product_id. The next join’s referencing operand is the whole previous result, so the inner form could remove that row. A LEFT key join at the final step preserves it.
This is why checking only a column’s base-table NOT NULL declaration is insufficient. The guarantee concerns each incoming row of the current referencing operand.

**Source footer:** TAS-028R1, nullability derivation and preservation requirements

## A4 — The questions predate our proposal

**On-screen context:** Appendix · Earlier work

Source: historical review reproduced in UTC-107 pp.23–31 and CMN-023R3 pp.29–35. REN-025 (Mike Sykes, 1986) proposes links; FIR-078 (Hugh Darwen, 1989) raises views, filtered targets and related issues; SLC-035 (Ken Jacobs, 1990) discusses adding a second FK. These are antecedents, not identical versions of the present design.
CMN-023R2/R3 compare SQL Anywhere’s inferred KEY JOIN to explicit column lists. The goal here is stable selection of the relationship plus proof through the actual operands. Avoid claiming to have invented every element of FK-based join notation.

**Source footer:** Historical review in UTC-107 / CMN-023R3; SQL Anywhere comparison in CMN-023R2/R3

## Source files

- [Full planning transcript](</Users/joel/Downloads/Key Joins Valencia - transkription.md>)
- [Written background](</Users/joel/Downloads/Historien om Key Joins från idé till standard.md>)
- [Paper and minutes catalogue](/Users/joel/Documents/ISO-WG3-meetings/key-joins-papers-and-meeting-minutes.md)
- [All paper summaries](/Users/joel/Documents/ISO-WG3-meetings/key-joins-papers-and-responses.md)
- [PGConf.EU session description](https://www.postgresql.eu/events/pgconfeu2026/sessions/session/8343-designing-a-new-sql-language-feature-key-joins/)
- [Public demo](https://keyjoin.org/)
- [v15 patch posting](https://www.postgresql.org/message-id/bd598b83-9371-4857-90e4-4d5ded4613b5%40malkut.net)

Meeting identifiers on slide footers are resolved to full local PDF links in the paper/minutes catalogue. A minutes document is normally filed in the following meeting folder; its prefix is not the date of the meeting it describes.

## Suggested cuts if rehearsal runs long

Skip slides 8 (Syntax bikeshedding) and 12 (MATCH predicate), and shorten slide 21 (meeting Arne) to its essential introduction. Keep the fan-trap example, the breakthrough, the scope diagram and the final contract. The appendix is not part of the scheduled talk.
