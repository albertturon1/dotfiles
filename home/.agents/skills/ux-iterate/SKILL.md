---
name: ux-iterate
description: Show UI variants with realistic data, screenshots, and explained labels before the user judges them. Use when the user asks what a screen should look like, rejects a variant, or says a layout or label makes no sense.
---

# UX iterate

Generate variants with `prototype` (its UI branch). Run this gate before showing any variant:

1. **Data.** Fill the screen with realistic data: the repo's seed, plus an empty case, a one-item case, and a long-names case. Done when the variant renders without placeholders.
2. **Screenshots.** Render each variant at phone and desktop widths with `agent-browser` and list the absolute screenshot paths.
3. **Glossary.** Write one line per visible label, number, and icon: what it means and where its value comes from. A label that needs more than one line gets renamed or removed.
4. **Copy.** Every string answers a decision the user is making at that moment. Diff-style text ("+2 dishes, −1 dish"), counts that change nothing, and internal terms go.
5. **Real estate.** Measure fixed chrome (header, banners, bars) against the viewport height with `agent-browser eval` and report the percentage at phone width.
6. **Present** two or three variants with their trade-offs and a recommendation. Record each principle the user states (a rejection reason counts) as a proposed line for the repo's UI guidelines doc.
