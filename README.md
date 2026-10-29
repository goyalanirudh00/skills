# Skills

My personal collection of [Claude skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview). Each skill is a folder under `skills/` with a `SKILL.md` and any supporting files.

## Skills

| Skill | Use it for |
| --- | --- |
| [skimmable-bulk-text](skills/skimmable-bulk-text/SKILL.md) | Writing many short parallel items people skim: titles, alerts, notifications, dashboard cards, summary columns |

## Install

**Claude Code**

```
/plugin marketplace add <github-user>/skills
/plugin install anirudh-skills@anirudh-skills
```

**claude.ai / Claude app**

```
./scripts/package.sh            # builds dist/<skill>.zip for every skill
```

Then upload the zip under Settings > Capabilities > Skills.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. Add a row to the table above.
3. Bump `version` in `.claude-plugin/plugin.json`.
