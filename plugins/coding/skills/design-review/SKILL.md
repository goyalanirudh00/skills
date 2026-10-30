---
name: design-review
description: Review a system design, architecture, RFC, pipeline or infrastructure change for failure classes that don't show up in a diff, plus SOC 2 readiness and scalability. Use when asked to review a design, plan, workflow, IaC or CI/CD change, or before building something with multi-step side effects, permissions or concurrency.
---

# Design review

Find the defects that live between components, between steps and between environments: the ones a line-by-line code review misses. The review produces a short list of findings, each tied to a concrete failure scenario, plus diagrams that show where the risks are.

## Inputs

Work from whatever exists: a design doc, an RFC, a diagram, a PR, IaC, workflow files, or a verbal description. If the design is only in someone's head, ask for a one-paragraph description and the list of components before starting.

## Step 1: Understand before judging

Write back, in a few lines:

- What the system does and who triggers it.
- The components, and every external write or side effect, in order.
- The identities involved and what each can do.
- What "done" and "failed" mean.

If the design is vague or the goals conflict, stop and clarify before reviewing. When the `grill-me` skill is available, offer it for a structured interview.

## Step 2: Walk the failure classes

Read [references/failure-classes.md](references/failure-classes.md). For each of the 15 classes, decide one of:

- **Finding**: the design has this problem. Write it up (Step 5).
- **Covered**: the design handles it. Note how in one line.
- **N/A**: the class does not apply. Say why in a few words.

Do not skip classes silently. A reviewer reading the output should see that all 15 were considered. The fastest path: classes 1, 2, 3, 5, 8 and 9 catch the most in practice, so start there.

## Step 3: SOC 2 readiness

Read [references/soc2-readiness.md](references/soc2-readiness.md). Check Security (always) and Availability (by default); ask whether Confidentiality, Processing Integrity or Privacy are in scope. State clearly that the review assesses whether the design supports the controls, not whether it passes an audit.

## Step 4: Scalability

Read [references/scalability.md](references/scalability.md). Start by asking for current and 12-month load. If nobody knows, record that as a finding and review against a stated assumption.

## Step 5: Write findings

One block per finding, all in the same shape:

```
[Severity] <Class name>: <short title>
Where: <component, file, step>
Failure: <concrete scenario: what happens, in what order, with what result>
Fix: <smallest change that closes it>
```

Severity:

- **High**: data loss, security exposure, outage, or a state that needs manual repair.
- **Medium**: wrong behavior in a realistic edge case, or a control that might not hold.
- **Low**: hardening, clarity or a missing check with limited impact.

Rules:

- Every finding needs a concrete failure scenario. "Could be a race condition" is not a finding; "two runs both read version 4 and both write version 5" is.
- Order findings by severity, then by how cheap the fix is.
- Keep findings parallel and skimmable. When the `skimmable-bulk-text` skill is available, follow it for the list.
- Separate opinions and style preferences from findings, in a short "Notes" section at the end.

## Step 6: Diagrams

Draw the views that make the findings visible. When the `diagram-design` skill is available, use it; otherwise use Mermaid.

- **Architecture with trust boundaries**: components, identities, and which paths cross a boundary. Mark permitted and blocked paths. Show where each High finding sits.
- **Sequence of side effects**: for any multi-step operation (class 1, 2, 3), show each write in order and mark the point where a failure leaves bad state.
- **State machine**: for anything with a lifecycle (releases, jobs, alerts, approvals), show states, transitions and terminal outcomes, including failed and abandoned.
- **Access matrix**: identities against resources and permissions, when least privilege (class 8) is in question.

Draw only what helps. A small design may need one diagram.

## Step 7: Optional deep check for concurrency

If the design has concurrent state transitions where ordering bugs would be costly (locks, leases, retries across services, distributed workflows), suggest modeling it formally. The pstack `statechart` skill can check every interleaving with TLC and draw the result. Recommend it; don't require it.

## Output format

```
# Design review: <system>

## Summary
<2-3 sentences: overall risk, the top 1-3 findings, and the verdict:
ready / ready with fixes / needs redesign>

## Findings
<findings, highest severity first>

## Failure class coverage
<15 lines: class name, then Finding / Covered / N/A with a few words>

## SOC 2 readiness
<findings and gaps by criteria; then "Out of scope for a design review">

## Scalability
<load assumption, then findings>

## Diagrams

## Notes
<opinions, style, questions for the author>
```

## Using the principles while building

The same 15 classes work as rules while writing code. When implementing anything with external side effects, permissions, retries or concurrency, check the work against each class's **Principle** line before calling it done.
