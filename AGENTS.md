# Agent Operating Rules — mikaelairlangga-site

Both Claude Code and Codex must follow this file. `CLAUDE.md` is the detailed project
memory (what this repo is, deploy flow, infra pointers into the Obsidian vault) — read it
before substantial work and keep the two files in sync.

## Dual Review (Claude + Codex)

Every implementation change closes with **two reviews before commit**:

1. **Self-review by the implementing agent.** Claude closes with `/code-review` (plus
   `/verify` when there is runtime behavior to drive); Codex reviews its own diff against
   the acceptance criteria.
2. **Independent cross-review by the other agent.** When Claude implements, it delegates a
   review of the uncommitted diff to Codex (the `codex-review` subagent). When Codex
   implements, the diff gets a Claude review before commit.

Address the findings worth addressing before committing; surface disagreements to the user
rather than silently dropping them. The cross-review is **non-blocking**: if the other
agent is unavailable, say so and fall back to a user review — never skip silently.
Trivial changes (typo/docs-only edits, lockfile churn, generated files) don't need the
cross-review.
