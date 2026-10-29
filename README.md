# Skills

My personal collection of [Claude skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview), grouped by category. Each category is a Claude Code plugin under `plugins/`, and each skill is a folder with a `SKILL.md`.

## Skills

| Category | Skill | Use it for |
| --- | --- | --- |
| coding | [karpathy-guidelines](plugins/coding/skills/karpathy-guidelines/SKILL.md) | Avoiding common LLM coding mistakes: overcomplication, unrequested changes, unverified work. Vendored from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT) |
| writing | [skimmable-bulk-text](plugins/writing/skills/skimmable-bulk-text/SKILL.md) | Writing many short parallel items people skim: titles, alerts, notifications, dashboard cards, summary columns |

## Install

**Claude Code**

```
/plugin marketplace add <github-user>/skills
/plugin install coding@anirudh-skills
/plugin install writing@anirudh-skills
```

Install only the categories you want.

**claude.ai / Claude app**

```
./scripts/package.sh                 # builds dist/<skill>.zip for every skill
./scripts/package.sh <skill-name>    # or just one
```

Then upload the zip under Settings > Capabilities > Skills.

## Adding a skill

1. Create `plugins/<category>/skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. For a new category, add `plugins/<category>/.claude-plugin/plugin.json` and an entry in `.claude-plugin/marketplace.json`.
3. Add a row to the table above and bump that category's `version`.

## Vendored skills

Third-party skills keep an `UPSTREAM.md` with their source and commit. Run `./scripts/sync-upstream.sh` to pull updates, then review the diff before committing.
