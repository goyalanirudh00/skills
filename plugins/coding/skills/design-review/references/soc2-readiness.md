# SOC 2 readiness checks

SOC 2 is an audit of how an organization operates its controls over time. A design cannot be "SOC 2 compliant" on its own. What a design can do is make the controls easy to operate and easy to prove. This file checks for that.

Always state this limit in the review: findings here mean "the design supports or undermines these controls," not "this passes an audit."

Group checks by the Trust Services Criteria. Security (the Common Criteria) applies to every SOC 2 report; the others apply only if the organization includes them in scope. If you don't know the scope, review Security and Availability, and ask about the rest.

---

## Security: Common Criteria

### Logical access (CC6)

- Is every human and machine identity named, with an owner?
- Is access least privilege (see failure class 8)? Are admin paths separate from normal use?
- Is access granted through roles or groups, not individual grants, so it can be reviewed?
- Are credentials short-lived? Are long-lived secrets in a secrets manager, rotated, and never in code or logs?
- Is MFA required for human access to production and to the systems that control it (cloud console, CI, source control)?
- Are trust boundaries drawn, and is data encrypted in transit across each one?
- Is sensitive data encrypted at rest, and who controls the keys?
- Is there a way to revoke access quickly when someone leaves?

### System operations and monitoring (CC7)

- Are security-relevant events logged: logins, permission changes, deploys, data exports, admin actions?
- Are audit logs tamper-resistant (append-only, separate account, retention set)?
- Does anything alert on suspicious activity, or do logs only exist for after the fact?
- Are failures surfaced, not swallowed (see failure class 9)?
- Is there an incident path: who gets paged, and where is the runbook?

### Change management (CC8)

- Does every production change go through version control and review?
- Is there separation of duties: can one person write, approve and deploy alone?
- Are deploys automated and traceable from commit to running artifact (see failure class 6)?
- Can infrastructure be changed by hand outside the pipeline? If so, is drift detected (see failure class 4)?
- Is emergency change ("break glass") possible, logged and reviewed afterwards?

### Risk and vendors (CC9)

- Which third-party services, libraries and actions does the design depend on?
- Do any of them receive sensitive data or hold credentials?
- Are third-party dependencies pinned and their supply-chain risk known?

---

## Availability (A1)

- What are the availability and recovery targets (RTO, RPO), and does the design meet them?
- Are backups automatic, encrypted, stored separately, and has a restore been tested?
- Is there a single point of failure (one AZ, one region, one person with access)?
- Is capacity monitored, with alerts before limits are hit?

## Confidentiality (C1)

- Is confidential data identified and classified?
- Is it kept only as long as needed, then deleted, with deletion verifiable?
- Does it leak into logs, error messages, analytics or lower environments?

## Processing integrity (PI1)

- Is input validated (see failure class 14)?
- Are multi-step operations atomic or recoverable (see failure classes 1 and 2)?
- Are outputs complete and accurate, with reconciliation where data moves between systems?

## Privacy (P)

- Is personal data collected only for a stated purpose?
- Can a person's data be found, exported and deleted on request?

---

## What a design cannot cover

List these in the review as out of scope so nobody assumes the design handles them:

- Written policies (access review cadence, onboarding and offboarding, vendor review).
- Evidence collection over the audit window.
- Security awareness training and background checks.
- Risk assessments and their sign-off.
