---
name: "skimmable-bulk-text"
description: "Use when generating many short parallel text items people will skim: titles, alerts, notifications, list entries, dashboard cards, table summaries, digests."
---

# Skimmable Bulk Text

When you generate a set of short items that a person will scan rather than read (session titles, anomaly alerts, notification digests, summary columns, theme cards, headlines), the reader compares items to each other at a glance. Every inconsistency costs them time and every pointless difference looks like a signal. Apply the rules below to the set as a whole, not item by item.

Based on Shreya Shankar, "Five Principles for Generating Readable AI Text in Bulk" (FSDL blog, Oct 2026): https://fsdatalab.github.io/blog/agent-text-at-scale/

## Before writing: pick one template

Decide the shape of every item before generating any of them. Write it down, for example:

- Session titles: `<verb-ing> <object> [<qualifier>]`
- Alerts: `<entity> <direction + metric> <magnitude> <timeframe>`
- Review themes: `<N> users <love|complain about|request> <thing>`

Every item in the set uses the same template. If an item truly does not fit, that is information: put it in a separate group rather than bending the template.

## The five rules

1. **Lead with subject or verb, in a predictable order.** Use a subject-verb-object shape. If every item shares the same subject ("the user", "this issue"), drop it. Keep one tense across the set (for in-progress work, the -ing form works well).

2. **Front-load the distinguishing words.** Readers often take in only the first two words of each line. The part that makes this item different from its neighbors (the entity, the status, the direction of change) goes first. Shared boilerplate goes last or disappears.
   - Weak: `Your order from Store X has shipped`
   - Strong: `Shipped: Store X order`

3. **Same structure, same vocabulary.** Parallel items should be grammatically parallel. Use exactly one term per concept across the whole set. Never call the same thing an "issue" in one row and a "ticket" or "page" in another. Keep lengths roughly comparable.

4. **Vary only when the difference means something.** Readers assume any difference in format, length, or included detail carries meaning. If one card mentions a version number and others do not, the reader will wonder why. Either include a field for all items or for none. Use visible variation (an extra field, a badge, a different verb) only to mark a real difference such as severity or category.

5. **Match verb connotation to the content.** Use clearly positive verbs for positive items ("love", "praise", "improved") and clearly negative ones for problems ("complain", "fail", "dropped"). Avoid neutral openers like "discuss" or "mention" when the content is plainly good or bad, since they hide the valence the reader is scanning for.

## After writing: check the set

Read only the first two words of every item in a column. Then check:

- [ ] Can I tell the items apart from those words alone?
- [ ] Does every item follow the same template and tense?
- [ ] Is each concept named with exactly one term?
- [ ] Does every difference in format or detail correspond to a real difference?
- [ ] Does each verb's tone match the item's actual sentiment?
- [ ] If items have counts or magnitudes, are they in the same position and unit everywhere? Consider ordering by them or adding a simple bar chart.

Fix failures by revising the whole set together, not just the offending item.

## Scope

This is for parallel, skimmable items. It does not apply to long-form prose, single messages, or narrative explanations, where varied sentence structure reads better.