# Skills

My personal collection of [Claude skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview), grouped by category. Each category is a Claude Code plugin under `plugins/`, and each skill is a folder with a `SKILL.md`. Third-party skills I rely on are listed too, installed from their own repos so they stay current.

## My skills

| Category | Skill | Use it for |
| --- | --- | --- |
| coding | [karpathy-guidelines](plugins/coding/skills/karpathy-guidelines/SKILL.md) | Avoiding common LLM coding mistakes: overcomplication, unrequested changes, unverified work. Vendored from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT) |
| coding | [design-review](plugins/coding/skills/design-review/SKILL.md) | Reviews a design, pipeline or infra change against 15 failure classes that don't show up in a diff, plus SOC 2 readiness and scalability, with diagrams. The 15 principles also come as a [CLAUDE.md block](claude-code/CLAUDE-principles.md) for everyday coding |
| coding | [git-guardrails-claude-code](plugins/coding/skills/git-guardrails-claude-code/SKILL.md) | Sets up a hook that blocks dangerous git commands (push, `reset --hard`, `clean -f`, `branch -D`). Run it per project on repos where Claude should never push. Needs `jq`. From [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) |
| writing | [skimmable-bulk-text](plugins/writing/skills/skimmable-bulk-text/SKILL.md) | Writing many short parallel items people skim: titles, alerts, notifications, dashboard cards, summary columns |
| productivity | [grill-me](plugins/productivity/skills/grill-me/SKILL.md) + [grilling](plugins/productivity/skills/grilling/SKILL.md) | A relentless interview to find holes in a plan or design before building. Invoke with `/grill-me`. From mattpocock/skills (MIT) |
| productivity | [handoff](plugins/productivity/skills/handoff/SKILL.md) | Condense a long session into a document a fresh agent can pick up. From mattpocock/skills (MIT) |
| productivity | [writing-for-agents](plugins/productivity/skills/writing-for-agents/SKILL.md) | How to write skills, AGENTS.md and CLAUDE.md files that agents follow well. From mattpocock/skills (MIT) |
| security | [security-audit](plugins/security/skills/security-audit/SKILL.md) | Whole-repo security audit: maps trust boundaries, hunts with parallel subagents, and has fresh agents verify each finding before it lands in `findings.json` and a report. Answers security questions in a light guidance mode by default; the full six-phase run starts only when you ask for an audit or pen test. Full runs are costly, so ask for the `quick` profile or set an agent budget on large repos. Needs Node for its validators. From [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) (MIT) |
| visualization | [diagram-design](https://github.com/cathrynlavery/diagram-design) | Editorial HTML/SVG diagrams in 45 types, including architecture, sequence, ER and trust-boundary views. Third-party (MIT), linked from upstream since it updates weekly |

### Per-project: Superpowers

[obra/superpowers](https://github.com/obra/superpowers) (MIT) is listed in this marketplace but **not enabled globally**. It enforces a full process: brainstorm, write a plan, test-first, hand work to subagents, verify before finishing.

- **Turn it on** for big new builds (multi-day features, greenfield products) where planning and tests up front save rework.
- **Leave it off** for small fixes and for client codebases, where karpathy-guidelines' "touch only what you must" is the better fit.

To enable it in one project, merge [`claude-code/project-superpowers.json`](claude-code/project-superpowers.json) into that project's `.claude/settings.json`, or run `/plugin install superpowers@anirudh-skills` from inside the project and choose project scope. It runs alongside karpathy-guidelines without conflict.

## Third-party picks

Installed from the publishers' own marketplaces. Only the plugins below are enabled, not the whole collections.

**Security: [Trail of Bits](https://github.com/trailofbits/skills)** (CC-BY-SA-4.0)

| Plugin | Use it for |
| --- | --- |
| static-analysis | CodeQL and Semgrep scans, SARIF parsing |
| differential-review | Security review of a diff or PR, using git history |
| insecure-defaults | Hardcoded credentials, fallback secrets, weak crypto, debug features left on |
| sharp-edges | Error-prone APIs, dangerous configs, footgun designs |
| supply-chain-risk-auditor | Risk audit of npm, PyPI and Go dependencies |
| agentic-actions-auditor | GitHub Actions workflows that run AI agents |

**Infrastructure: [HashiCorp](https://github.com/hashicorp/agent-skills)** (MPL-2.0)

| Plugin | Use it for |
| --- | --- |
| terraform | Style guide, modules, tests, imports, stacks, policy, provider development |

## Install

**Claude Code, everything at once:** merge [`claude-code/settings.json`](claude-code/settings.json) into `~/.claude/settings.json` and restart Claude Code. It registers all three marketplaces and enables exactly the plugins above.

**Claude Code, by hand:**

```
/plugin marketplace add goyalanirudh00/skills
/plugin install coding@anirudh-skills
/plugin install writing@anirudh-skills
/plugin install productivity@anirudh-skills
/plugin install security@anirudh-skills
/plugin install diagram-design@anirudh-skills

/plugin marketplace add trailofbits/skills
/plugin install static-analysis@trailofbits      # and the others listed above

/plugin marketplace add hashicorp/agent-skills
/plugin install terraform@hashicorp
```

**Other agents (Cursor, Codex, etc.):** `npx skills add cathrynlavery/diagram-design`, `npx skills add hashicorp/agent-skills`.

**claude.ai / Claude app**

```
./scripts/package.sh                 # builds dist/<skill>.zip for every skill in this repo
./scripts/package.sh <skill-name>    # or just one
```

Then upload the zip under Settings > Capabilities > Skills. For a third-party skill, zip its skill folder from the upstream repo instead.

## Adding a skill

1. Create `plugins/<category>/skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. For a new category, add `plugins/<category>/.claude-plugin/plugin.json` and an entry in `.claude-plugin/marketplace.json`.
3. Add a row to the table above and bump that category's `version`.

For a third-party plugin, add it to the picks table and to `enabledPlugins` in `claude-code/settings.json`.

## Vendored skills

Third-party skills copied into this repo keep an `UPSTREAM.md` with their source and commit. Run `./scripts/sync-upstream.sh` to pull updates for all of them, then review the diff before committing. To vendor a new one, copy its folder, add an `UPSTREAM.md`, and add a line to the `VENDORED` list in that script.
