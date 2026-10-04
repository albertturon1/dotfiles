---
name: evidence-research
description: Investigate factual questions, assess claims, and explain what the evidence supports across domains. Use for questions about effectiveness, causes, or conflicting findings; mentioning a product does not imply purchase intent.
---

# Evidence research

Answer the user's question with evidence suited to the claim. Distinguish what is established, what is inferred, and what remains uncertain.

## Define the question

Identify the intended outcome from the conversation: understanding facts, assessing a claim, explaining disagreement, or applying findings to a decision. A product, technology, or service can be the subject of research without being a purchase candidate.

Ask only when unresolved ambiguity would materially change the answer. For broad questions such as “does it work?”, identify the relevant outcome, comparison, population or setting, and time horizon. When useful, cover the main interpretations briefly instead of requiring the user to choose before any research.

Use existing context and state consequential assumptions. Scale effort to the question's complexity, stakes, and requested depth. Answer in the conversation by default; create a research file when requested or when an agreed workflow needs one. A repository or background agent is not required.

## Match sources to claims

Select evidence by its ability to support the specific claim, rather than applying one source hierarchy to every topic:

- **Effects and causation:** use well-conducted evidence syntheses and relevant original studies. Examine study design, comparison groups, confounding, effect size, uncertainty, and applicability. A systematic review can be more informative than an isolated primary study; inspect its methods, search date, and included evidence.
- **Technical performance:** use reproducible measurements, independent tests, and transparent benchmarks. Check versions, test conditions, workloads, and whether the measured outcome matches the user's question.
- **Documented behavior and formal facts:** use authoritative records, standards, official documentation, source code, or original datasets. Documentation establishes intended behavior; observations or tests establish actual behavior in a particular environment.
- **Experience and implementation problems:** use qualitative studies, field reports, and firsthand accounts for context and possible failure modes. Anecdotes and ratings do not establish comparative effectiveness or prevalence.

Use secondary explanations to orient the search and locate stronger evidence. Inspect the underlying sources for conclusion-driving claims. Search snippets, abstracts, and summaries may omit limitations; disclose when full methods or results could not be inspected.

Assess source quality, relevance, and independence separately. Several articles repeating one study count as one underlying body of evidence. Check material funding, sponsorship, affiliate incentives, and editorial involvement; a disclosed conflict is a reason for scrutiny, not an automatic verdict on validity.

## Investigate the evidence

Search for the strongest relevant evidence and credible challenges to the emerging conclusion. Choose queries that can uncover null findings, limitations, and competing explanations as well as supportive results.

For claims that drive the answer, keep compact working notes with the source, what it directly supports, its main limitations, and any inference needed to apply it. No fixed source count is required: one authoritative record may settle a narrow fact, while a contested causal claim needs broader triangulation.

Check dates, versions, jurisdictions, corrections, and retractions when they could change the conclusion. For changing facts, verify the current state and give the date checked. Clearly label information that could not be verified with available access.

Preserve distinctions that affect interpretation:

- a plausible mechanism versus a demonstrated outcome;
- association versus causation;
- laboratory efficacy versus effectiveness in ordinary conditions;
- a proxy measurement versus an outcome the user actually cares about;
- statistical significance versus practical importance;
- absence of evidence versus evidence of little or no effect.

When quantitative effects matter, provide magnitude, units, baseline or comparator, and uncertainty where available. Explain whether a result transfers to the user's setting. Findings for one product, population, version, or context do not automatically establish a claim about the entire category.

When sources disagree, compare their definitions, methods, samples, dates, and measured outcomes. Weight them by quality and relevance rather than counting conclusions or presenting every position as equally supported. Preserve unresolved disagreements.

## Conclude within scope

Research is sufficient when the main interpretations of the question have been addressed, conclusion-driving claims have suitable support, important contrary evidence has been checked, and remaining gaps are identified. Stop when further searching is unlikely to change the answer or its confidence. If access or evidence is insufficient, report a partial or uncertain conclusion instead of extending the search indefinitely.

If the user also requests decision support, relate findings to their goals and constraints, separating empirical findings from preferences and trade-offs. Move to product selection and current offers only when the user expresses purchase intent. For an implementation request, use research to resolve relevant unknowns and continue the authorized task.

## Present the answer

Lead with the direct answer, including qualifications necessary to interpret it. Scale the structure to the question; a short answer need not become a report.

Include, when relevant:

- what the best evidence supports and the conditions under which it applies;
- the key findings, with direct source links next to the claims they support;
- the strength of the evidence and the concrete reasons for that assessment;
- important limitations, disagreements, and unanswered questions;
- practical implications if requested, and what evidence would change the conclusion.

Use qualitative confidence with an explanation rather than invented numerical certainty. Keep confidence specific to each major claim when the evidence varies across outcomes. Distinguish sourced findings from your synthesis and inference.
