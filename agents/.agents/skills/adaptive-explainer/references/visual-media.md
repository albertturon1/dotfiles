# Visual and interactive explainers

Use this reference only after selecting a diagram, explanatory image, or interactive webpage as the medium.

## Portability

Select available tools by capability rather than by a product-specific tool or skill name. Keep the result usable outside the environment that created it.

Prefer these portable outputs:

- Mermaid or readable ASCII for diagrams embedded in a conversation;
- SVG or standalone HTML for saved diagrams and vector illustrations;
- PNG or another common raster format for generated images;
- a self-contained `index.html` with inline CSS and JavaScript for interactive explainers.

Use external packages, hosted assets, APIs, or CDNs only when they materially improve the requested result and the environment supports them. Provide a static or textual fallback when the richer format cannot be created or displayed.

## Diagrams

Match the diagram type to the structure:

- flowchart for decisions and transformations;
- sequence diagram for messages between actors or components;
- state diagram for lifecycles and allowed transitions;
- architecture diagram for boundaries, ownership, and dependencies;
- timeline for change over time;
- concept map for terms and their relationships.

Keep only the nodes and edges needed for the explanation. Use the same label for the same concept everywhere. Label arrows with actions or data when direction alone is ambiguous. Include a legend only when the notation is not self-explanatory.

## Explanatory images

Use an image when visual appearance or spatial composition is part of the idea. Use available image-generation capability when present. For geometric, schematic, or text-heavy visuals, prefer SVG or HTML because they remain editable and render text reliably.

When raster image generation is unavailable, provide one of these fallbacks:

- an SVG illustration that can be created with the available file tools;
- a diagram that preserves the important spatial relationships;
- a production-ready image prompt that specifies subject, composition, labels, style, aspect ratio, and what the image must teach.

Add concise alt text or a caption stating what the viewer should notice. Treat decorative imagery as optional.

## Interactive webpages

Unless the user requests integration with an existing project, create one self-contained `index.html` that opens locally without a build step.

An interactive explainer should:

- present the central idea before the controls;
- start in a meaningful state;
- label controls with units and valid ranges;
- update the explanation as the state changes;
- provide reset or replay behavior when the interaction has multiple steps;
- work with keyboard input and remain readable on narrow screens;
- include a static summary for readers who cannot use the interaction.

Inspect or preview the page when the environment provides that capability. Verify the initial state, every control, the reset path, and the main narrow-screen layout before delivery.
