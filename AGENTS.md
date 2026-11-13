# Agent Operating Rules — mikaelairlangga-site

Both Claude Code and Codex must follow this file. `CLAUDE.md` is the detailed project
memory (what this repo is, deploy flow, infra pointers into the Obsidian vault) — read it
before substantial work and keep the two files in sync.

## Available-agent review


Use whichever agent runtime is available; no Claude subscription is required.
1. Review your own diff against acceptance criteria and run relevant checks.
2. For meaningful implementation changes, request a fresh reviewer using the available
   runtime's subagent facility. Another Codex agent is valid; another provider is optional.
3. If no second agent is available, perform a separate adversarial pass over the final diff,
   edge cases, failure paths, and test evidence. Report this as a solo second pass, never
   an independent review. Do not block solely because another provider is unavailable.
Address actionable findings and surface disagreements. Existing human approval gates for
publishing, issue creation, destructive operations, and unresolved risks still apply.
Trivial documentation, typo, generated-file, and lockfile changes need self-review only.
