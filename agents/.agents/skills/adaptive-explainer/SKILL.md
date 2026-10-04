---
name: adaptive-explainer
description: Turn difficult material into a clear, intuitive explanation when the user asks to explain, teach, simplify, visualize, or make a topic easier to understand. Select prose, a diagram, an explanatory image, or a standalone interactive webpage according to the idea and requested depth; answer in the language of the user's current request.
---

# Adaptive Explainer

Make the subject easier to understand without making it less true.

## Language continuity

- Write the skill instructions in English, but mirror the language of the user's current request in the result.
- An explicit language request overrides mirroring.
- In mixed-language conversations, follow the language used for the current task. Preserve code, quotations, product names, and established technical terms where translation would reduce precision.
- When a useful technical term is unfamiliar, explain it on first use. Include the original term in parentheses only when it helps the user recognize it elsewhere.

## Choose the medium

Use the lightest medium that makes the important structure easy to see:

- Use concise prose for definitions, arguments, and short conceptual explanations.
- Add a diagram for processes, relationships, hierarchies, feedback loops, timelines, or systems with several interacting parts.
- Create an explanatory image when appearance, geometry, spatial arrangement, or a visual analogy carries information that prose or a diagram would lose.
- Build an interactive explainer when changing parameters, comparing states, stepping through a process, or manipulating a model would materially improve understanding and the request supports creating an artifact.

Combine media when each one carries different explanatory work. Do not turn a simple question into a large artifact merely because richer media are possible.

When choosing a diagram, explanatory image, or interactive webpage, read [references/visual-media.md](references/visual-media.md) before creating the artifact.

## Explain

Infer the audience and desired depth from the conversation. If they are unclear, assume an intelligent non-specialist and proceed. Ask a question only when the missing answer would substantially change the result.

Start with the central idea or practical answer. Then build the user's mental model with only the components that help:

- a concrete analogy or example;
- the mechanism or sequence;
- a small diagram;
- why the idea matters;
- a common misconception or important boundary;
- a compact recap.

Use controlled-language principles at approximately 80% of ASD-STE100 strictness: short sentences, one main idea per sentence, active voice, concrete verbs, stable terminology, and explicit references. Apply these principles naturally in every output language. Prefer readability over literal compliance with an English-only rule.

Match the user's sophistication. Preserve necessary nuance, uncertainty, exceptions, and causal boundaries. Label analogies as analogies when they stop matching the real mechanism.

## Artifact behavior

When the user requests a diagram, image, webpage, or simulation, create the artifact when the environment supports it. Select tools by capability rather than by a product-specific skill name. Follow the portable formats and fallbacks in [references/visual-media.md](references/visual-media.md). Make interactive explainers usable without requiring the user to read their source code.

## Completion check

Before finishing, verify that the result lets the intended reader answer:

1. What is it?
2. How or why does it work?
3. What is one concrete example?
4. What limitation or distinction prevents the most likely misunderstanding?

Omit any item that does not apply. Stop when the explanation is complete; do not pad it with adjacent facts.
