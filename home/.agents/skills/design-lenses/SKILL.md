---
name: design-lenses
description: Apply design lenses to a plan or a code review: irreducible constraints, rewrite-first, a dissolving abstraction, the single breaking test, unenforced invariants, and implicit state machines. Use when planning a non-trivial change, reviewing a diff for correctness, or when asked what would break a design.
---

# Design lenses

A lens is one question plus a required output. Run the lenses that match the moment. Do not run all of them by default.

## Which lenses, when

- **Planning** (before writing code for a non-trivial change): constraints, rewrite-first, dissolving abstraction, breaking test.
- **Review** (a diff or branch): unenforced invariants, implicit state machines, breaking test.

## Rules for every lens

- Each item names a location (file and function) or says "not applicable".
- Each finding has a status: **observed** (you ran it) or **read in code** (you did not run it).
- An empty result is valid. Do not pad it.
- If the project has a rule that covers the lens, apply that rule (for example, the state-table rule in AGENTS.md).

## Lenses

### 1. Irreducible constraints (planning)

Question: which constraints are facts (a law, a data shape, an external API, a promise to the user), and which are habits?

Output: 3 to 7 facts, each with its source. List habits separately.

### 2. Rewrite first (planning)

Question: if you started from zero with the facts above, what would you build differently?

Output: the parts of the current plan that the rewrite removes, each with a reason. If nothing changes, say so.

### 3. Dissolving abstraction (planning)

Question: is there one abstraction that makes part of this problem disappear?

Output: its name, the cases it removes, and the cases it does not remove. If it removes nothing, reject it.

### 4. Breaking test (planning and review)

Question: which single test, written today, would break this design?

Output: the test name, its input, and the expected result. If the test cannot be written, say what stops it. For an interactive stress test use `grilling`. To run the test and prove it can fail, use `prove-it`.

### 5. Unenforced invariants (review)

Question: for each rule the code relies on, where is it enforced: a database constraint, the one function that writes the data, or nowhere?

Output: a table of rule, enforcement, and gap. A gap is any of: reliance on caller discipline, a check followed by a write without a transaction, or no check at all. Reproduce a gap before calling it a bug.

### 6. Implicit state machines (review)

Question: which combinations of flags, nullable fields, or timers encode a state that nobody named?

Output: the candidate states as a union type, and a state table with states as rows and events as columns, every cell filled. Make no change to the code unless asked.

## Boundaries

- This skill does not replace `prove-it` (proof after a change), `code-review` (standards and spec of a diff), or `code-maintainability` (refactoring).
- Stop at the outputs. Do not implement fixes unless the user asks.
