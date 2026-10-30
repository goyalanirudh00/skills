# Failure classes

Fifteen classes of defect that recur in designs and rarely show up in a diff. Each one reads two ways: as a **principle** to follow while building, and as **questions** to ask while reviewing.

Every class has the same parts:

- **Principle**: the rule, phrased as something to do.
- **Why it hides**: why a normal code review misses it.
- **Ask**: the review questions.
- **Example**: a generic case.
- **Usual fixes**: common ways to close it.

---

## 1. Non-atomic multi-step side effects

**Principle:** Make every multi-step change either all-or-nothing, or safely resumable from any step.

**Why it hides:** Each step looks correct on its own. The bug lives in the gap between steps, when the process dies after step 2 of 4.

**Ask:**
- List every external write in order. What state is left behind if the process stops after each one?
- Is there a transaction, a saga with compensating actions, or a resume marker?
- Which step is the commit point, the one after which the operation counts as done?

**Example:** A checkout flow charges the card, then writes the order record, then sends the confirmation. It crashes after the charge. The customer is billed, there is no order, and a retry charges them again.

**Usual fixes:** Do the irreversible or externally visible step last. Write intent first, then act, then mark complete. Make each step check whether it already happened (see class 2).

---

## 2. Idempotency and re-runnability

**Principle:** Running the same operation twice must be safe, and you must be able to say exactly what a retry does.

**Why it hides:** Tests run each operation once. Retries come from schedulers, humans, queues and CI re-runs, none of which appear in the code under review.

**Ask:**
- What happens if this runs twice with the same input? Twice at the same time?
- After a partial failure, can someone just re-run it, or does it need manual cleanup first?
- What is the idempotency key, and who generates it?

**Example:** A publish step creates a resource unconditionally. A retry after a timeout fails with "already exists," or worse, creates a duplicate.

**Usual fixes:** Create-if-absent or upsert semantics. Idempotency keys stored with the result. Check-and-skip for steps that already completed.

---

## 3. Race conditions and check-then-act gaps (TOCTOU)

**Principle:** Assume two copies of anything can run at once, and close every gap between checking a condition and acting on it.

**Why it hides:** Code reads sequentially. Concurrency comes from the deployment shape: two people clicking, two pipeline runs, two replicas.

**Ask:**
- What triggers this, and can two triggers overlap?
- Where does the code check something, then act on it later? What can change in between?
- If there is a lock, what exactly does it cover, who holds it, and what happens when the holder dies?

**Example:** A plan step computes a change, a human approves it, and an apply step runs it. Meanwhile a second run changes the same target, so the approved plan no longer matches reality.

**Usual fixes:** Concurrency groups or queues that serialize runs. Compare-and-swap or conditional writes. Re-validate inside the critical section. Locks with leases and clear ownership.

---

## 4. Coverage completeness and the inverse case

**Principle:** For any check, sync or reconciliation between two sources of truth, cover both directions, and write down what the check can never see.

**Why it hides:** A check that passes looks like proof. Nobody notices the category of problem it is structurally blind to.

**Ask:**
- Does this compare A to B only, or also B to A?
- What does the check enumerate? Anything outside that list is invisible to it.
- What kind of drift would this check report as "all clear"?

**Example:** A drift check verifies that everything declared in config matches what is deployed. A resource created by hand, never declared, is never examined, so it never shows up as drift.

**Usual fixes:** Two-way diffs. Enumerate from the live side as well as the declared side. Document known blind spots next to the check.

---

## 5. Silent no-ops and fail-open guards

**Principle:** Every control must fail closed, and must prove it enforces something.

**Why it hides:** The control exists and the config looks right. Nothing errors, so nothing gets investigated.

**Ask:**
- If this guard's dependency is missing or misnamed, does it block or allow?
- Has anyone seen this control actually deny something? Is there a test that expects a denial?
- Does any platform auto-create a missing thing with permissive defaults?

**Example:** A deployment references a protected environment by name. A typo means the platform silently creates a new, unprotected environment, and approvals are skipped. Another: an access-deny rule with the wrong condition key matches nothing.

**Usual fixes:** Negative tests that expect a denial. Assert the guard's prerequisites exist before relying on them. Prefer explicit allowlists over deny rules that can silently miss.

---

## 6. Mutable vs immutable references and provenance

**Principle:** Never assume a name pins content. Refer to artifacts by digest or other immutable identity, and know where every artifact came from.

**Why it hides:** Tags, branches and "latest" look like versions. They are pointers that can move.

**Ask:**
- Can the thing this reference points to change after we check it?
- Do we deploy what we tested, byte for byte? How do we know?
- Can anyone rebuild or re-push under the same name?

**Example:** A container image is deployed by tag. Someone re-pushes that tag, so production now runs different bytes from what passed testing.

**Usual fixes:** Pin by digest. Enforce tag immutability in the registry. Build once and promote the same artifact through environments. Record provenance (commit, build ID) with the artifact.

---

## 7. Implicit cross-component contracts

**Principle:** Any assumption two components share must be written down in one place and checked by at least one of them.

**Why it hides:** Each component is reviewed alone. The contract lives in neither file, only in the author's head.

**Ask:**
- What does this component assume about the format, naming or timing of something another component produces?
- If the other side changed its output tomorrow, what would break, and would anything tell us?
- Where is this contract documented?

**Example:** One service writes timestamps as local-time strings; another parses them as UTC. Both pass their own tests, and every record is off by several hours.

**Usual fixes:** A shared constant, schema or library. Validate the contract at the consuming side (see class 14). A comment in both places pointing at the other.

---

## 8. Least privilege

**Principle:** Grant the narrowest permissions, trust and token scope the task needs, and nothing that is merely convenient.

**Why it hides:** Broad permissions make everything work, so nothing fails in testing. The cost only shows up in an incident.

**Ask:**
- What is the smallest set of actions and resources this identity needs?
- Who or what can assume this role or use this token? Is the trust scoped to one repo, branch or workload?
- How long do credentials live?

**Example:** A CI identity trust policy accepts tokens from every repository in the organization, so any repo can deploy to production.

**Usual fixes:** Scope trust to specific repos, branches and environments. Resource-level permissions instead of wildcards. Short-lived credentials. Separate identities per environment.

---

## 9. Swallowed errors and unsurfaced failure

**Principle:** Every failure must either stop the process or be reported where someone will see it. Never discard an error on the way to "success."

**Why it hides:** The happy path works. The swallowed error only matters on the day something goes wrong, and then the logs say everything passed.

**Ask:**
- Are any exit codes ignored, or any errors caught and dropped?
- In shell, is `set -euo pipefail` on? Any `|| true`?
- Does anything silently truncate, cap or paginate so that part of the data is skipped?

**Example:** A script pipes a command into another; the first fails, but without `pipefail` the pipeline reports success. Another: an API returns the first 100 results and the code treats that as the full set.

**Usual fixes:** Strict shell mode. Explicit handling for every caught error. Assert completeness (counts, pagination tokens). Alerts on partial results.

---

## 10. Boundary and first-run cases

**Principle:** Design for the empty, the first and the missing as deliberately as for the normal case.

**Why it hides:** The author tests in an environment that already has history. The first real run in a new environment is the first time the code meets "nothing."

**Ask:**
- What happens with an empty list, zero results, or no previous version?
- What happens on a cold start, in a brand-new account or region?
- What if a resource this depends on does not exist yet?

**Example:** A version bump reads the last tag and increments it. In a new repo there is no last tag, and the job crashes, or quietly produces version `NaN`.

**Usual fixes:** Explicit defaults for "no prior state." Tests that start from an empty environment. Bootstrap steps that are idempotent.

---

## 11. Rollback and recovery path

**Principle:** Every change needs a known, tested way back, and that way back must not be blocked by your own guarantees.

**Why it hides:** Rollback is designed last, if at all, and rarely tested until it is needed in an incident.

**Ask:**
- How do we undo this? Has anyone actually done it?
- Does rollback conflict with another guarantee (immutability, migrations, compliance retention)?
- What data is lost or must be repaired if we roll back?

**Example:** A migration drops a column after copying its data. Rolling back the code is easy, but the old code needs the column, which is gone.

**Usual fixes:** Roll forward with a revert release. Backwards-compatible migrations (expand, then contract). A rollback runbook that has been exercised. Feature flags for risky behavior.

---

## 12. Environment and platform assumptions

**Principle:** Write down every behavior you rely on from the environment or platform, and check the critical ones at runtime.

**Why it hides:** It works on the author's machine, in the author's account, with the author's credentials. Platform behaviors feel like facts until they change.

**Ask:**
- What credentials, MFA, region, account or tools must be present?
- Which platform behaviors does safety depend on? Are they documented, and could a setting change them?
- What differs between local, CI, staging and production?

**Example:** A script never sets a region and relies on whatever the developer's CLI defaults to. It works for the author, then creates resources in the wrong region when a teammate or the CI runner runs it.

**Usual fixes:** Preflight checks that fail fast with a clear message. A short "assumptions" section in the design. Pin tool and platform versions where behavior matters.

---

## 13. Eventual consistency and stale reads

**Principle:** Never assume a value you just wrote is immediately readable everywhere, or that a value you read earlier is still true when you act.

**Why it hides:** In testing, everything is fast and local, so reads always see the latest write.

**Ask:**
- Is any read served by a cache, replica or eventually consistent store?
- Does the code read its own write right away? Across services?
- How old can a value be by the time it is used?

**Example:** A new access role is created and used in the next line. The identity service has not propagated it yet, so the first call fails intermittently.

**Usual fixes:** Read from the primary for read-after-write. Retry with backoff on "not found" right after creation. Carry versions or ETags and re-check before acting.

---

## 14. Input validation and trust boundaries

**Principle:** Validate the shape and source of every input that crosses a trust boundary before you parse or act on it.

**Why it hides:** Inputs usually come from "our own" systems, so they feel trusted. Trust boundaries are rarely drawn on the design.

**Ask:**
- Where does each input come from, and who can influence it?
- Is it checked against a strict format before use?
- What happens with a malformed, oversized or malicious value?

**Example:** A webhook handler takes a branch name from the request payload and puts it into a shell command. A branch named with shell metacharacters runs arbitrary commands. Validating against a strict pattern first closes it.

**Usual fixes:** Strict allowlist patterns. Parse into typed structures and reject on failure. Mark trust boundaries on the architecture diagram.

---

## 15. Resource cleanup and orphans

**Principle:** Every resource you create must have an owner and a cleanup path, including on the failure and abandon paths.

**Why it hides:** Cleanup is written for the success path. Failures leave debris that nobody tracks, and it accumulates cost and confusion.

**Ask:**
- If this fails or is abandoned halfway, what is left behind?
- How would we find orphans later? Are resources tagged with an owner or run ID?
- Does anything retry into a growing pile of leftovers?

**Example:** A failed environment setup leaves a load balancer and two disks running. Nobody owns them, they cost money every month, and nobody knows whether they are safe to delete.

**Usual fixes:** Create in a staging state and promote on success. Tag resources with run IDs. Periodic reaper jobs. `finally` or trap handlers for cleanup.

---

## Maintaining this list

This is a living list. Add a class when the same miss appears twice in reviews or retros; remove one when it stops recurring. Keep examples generic so the list can travel between projects.
