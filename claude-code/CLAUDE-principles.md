# Engineering principles

Paste this block into `~/.claude/CLAUDE.md` (all projects) or a project's `CLAUDE.md` so Claude follows it while writing code, not only in reviews. Details and review questions for each are in the `design-review` skill.

When writing code with side effects, permissions, retries or concurrency:

1. Make every multi-step change all-or-nothing, or safely resumable from any step.
2. Make re-running safe, and be able to say exactly what a retry does.
3. Assume two copies can run at once; close every gap between checking and acting.
4. Make checks and syncs cover both directions, and note what they can't see.
5. Make controls fail closed, and prove each one actually denies something.
6. Reference artifacts by immutable identity (digest), never by a movable name.
7. Write down any contract two components share, and validate it on one side.
8. Grant the narrowest permissions, trust and token scope the task needs.
9. Never swallow an error: fail, or report it where someone will see it.
10. Handle the empty, the first run and the missing resource on purpose.
11. Keep a tested way back that your other guarantees don't block.
12. Write down every environment and platform behavior you rely on; check critical ones at runtime.
13. Don't assume a write is readable immediately, or a read is still true when you act.
14. Validate the shape and source of every input that crosses a trust boundary.
15. Give every resource you create an owner and a cleanup path, including on failure.
