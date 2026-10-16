---
name: adaptive-explainer
description: Turn difficult material into a clear, intuitive explanation when the user asks to explain, teach, simplify, visualize, or make a topic easier to understand. Select prose, a diagram, an explanatory image, or a standalone interactive webpage according to the idea and requested depth; answer in the language of the user's current request.
---

# Adaptive Explainer

Make the subject easier to understand without making it less true.

## Establish the reader's need

Infer the audience, desired depth, and central question from the conversation. When unspecified, assume an intelligent non-specialist and proceed. Ask for clarification only when the answer would substantially change the explanation.

Mirror the language of the current request unless the user explicitly chooses another language. Preserve code, quotations, product names, and technical terms where translation would reduce precision. Explain unfamiliar terms and abbreviations on first use.

## Choose the medium

Honor the user's requested format. Otherwise, use the simplest medium that reveals the important structure:

- **Prose:** definitions, arguments, and short conceptual explanations.
- **Diagrams:** processes, relationships, hierarchies, feedback loops, timelines, and interacting components.
- **Explanatory images:** appearance, geometry, spatial arrangements, or visual analogies that carry essential information.
- **Interactive webpages:** ideas that become clearer when the reader changes parameters, compares states, steps through a process, or manipulates a model.

Combine media when each contributes something useful to the explanation. Scale the artifact to the question.

Before creating a diagram, explanatory image, or interactive webpage, read [references/visual-media.md](references/visual-media.md) for formats, tool selection, fallbacks, and presentation checks.

## Build the explanation

Lead with the central idea or practical answer. Introduce the components in the order the reader needs them.

Choose the supporting elements that address the reader's question: a concrete example, an analogy, the mechanism, a diagram, practical consequences, or a boundary that prevents misunderstanding. Let the subject determine the structure.

Match the reader's sophistication. Preserve uncertainty, exceptions, and distinctions that affect the conclusion. When using an analogy, explain where it stops matching the actual mechanism.

## Write clearly

Use a relaxed controlled-language style inspired by ASD-STE100. Treat “80% of the way to ASD-STE100” as a stylistic cue, not a compliance score. The following rules are the operative instructions:

- Prefer short sentences with one main idea.
- Use active voice and concrete verbs where they make the meaning clearer.
- Use the same term for the same concept throughout.
- Make the referent of pronouns such as “it” and “this” clear.
- Explain necessary jargon; replace unnecessary jargon with familiar words.
- Keep sentences naturally connected. Use a longer sentence when it expresses a relationship more clearly than several fragments.

Apply these principles in the reader's language. Prioritize readable, precise explanations over literal compliance with an English-language specification.

## Create and verify artifacts

When the user requests an artifact, create it when the environment supports it. Select tools by capability and follow the formats and fallbacks in the visual-media reference. Make the result usable without requiring the reader to inspect its source code.

Check explanatory correctness as well as presentation:

- Diagram labels, arrows, and sequences must match the mechanism being explained.
- Charts must represent values, units, and scales consistently.
- Interactive controls and animations must produce states consistent with the stated model.
- Check a representative case and relevant boundary cases against a known result or an independent calculation.
- Make assumptions, illustrative values, and consequential simplifications visible.
- Distinguish conceptual demonstrations from empirically validated models.

If a check cannot be completed, state the specific limitation. Adjust unsupported precision or claims accordingly.

## Completion check

Use these questions internally, rather than as a required response outline:

1. Does the explanation answer the reader's central question?
2. Can the reader follow the relevant mechanism or reasoning?
3. Would a concrete example resolve any remaining abstraction?
4. Is the most likely consequential misunderstanding addressed?

Include only what the task needs. Finish when the explanation is sufficient; add a recap only when it helps the reader retain the idea.
