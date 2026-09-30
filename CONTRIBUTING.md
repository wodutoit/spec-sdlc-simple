# Contributing

This repo *is* the plugin. Its root is what lands at `.claude/skills/sdlc/` in a
product repo, so the layout is fixed by Claude Code's plugin spec rather than chosen.

## Branches

| Branch | Purpose |
|---|---|
| `main` | Development. Retro PRs land here. |
| `release` | What product repos clone. **A merge into it is a change advisory board decision**, performed by a human. |

Never push to `release` directly. Never merge your own PR.

## Working on the process

From a product repo, `/sdlc:retro` sets up a worktree for you. To work here directly:

```bash
git clone <this-repo> && cd spec-sdlc-simple
git checkout -b my-change origin/main
claude plugin validate . --strict
```

To dogfood the process in this repo, load it explicitly — the repo root is a plugin,
but Claude Code only auto-discovers plugins under `.claude/skills/`:

```bash
claude --plugin-dir .
```

Before opening a PR: `claude plugin validate . --strict` and `claude plugin eval`.

## Releasing

1. PR into `main`, reviewed.
2. Board approves → a human merges `main` into `release`.
3. `CHANGELOG.md` entry, with the `version` in `.claude-plugin/plugin.json` bumped.
4. Product repos pick it up with `/sdlc:bootstrap --relock`.

---

## Findings from setup — don't re-derive these

Verified against Claude Code **v2.1.177**. Re-check if a claim stops holding.

### Layout is not a choice

A skills-directory plugin puts its primary skill at the **root** `SKILL.md` and the
rest under `skills/<name>/SKILL.md`. The manifest must declare the root explicitly:

```json
{ "skills": ["./"] }
```

Use `"./"`, **not** `"."` — `"."` fails manifest validation before v2.1.221.

`claude plugin init <name> --with skills hooks` scaffolds the canonical shape if you
need to check it again.

### Gitignoring the clone is safe

Verified with a 4-way A/B (nested git repo × gitignored). Skill discovery **does not
consult `.gitignore`**, and a git repo nested inside `.claude/skills/` causes no
warning and no wrong path resolution. The parent repo's `git status` stays clean.

### Workspace trust is a real onboarding step

A project-scope skills-directory plugin is **not loaded until the workspace is
trusted**. Until then `claude plugin list` shows:

> ⚠ 1 project-scope plugin directory under ./.claude/skills/ was not loaded because
> this workspace was not trusted when plugins were scanned.

`-p` and SDK sessions never accept that dialog, so **the process does not load in
non-interactive or CI runs**. Where that matters, load it explicitly instead:

```bash
claude --plugin-dir .claude/skills/sdlc
```

That loads as `sdlc@inline` and bypasses trust. It's also the only way to verify
loading from a non-interactive session.

### Hook output channels

`SessionStart` has two distinct channels, and the staleness check uses both:

- `systemMessage` → shown to **the user**
- stdout / `hookSpecificOutput.additionalContext` → goes into **Claude's** context

`PreToolUse` blocks on **exit 2**, with stderr shown to the agent. That's what
`scripts/block-merge.sh` relies on.

Hooks cost **no model context** — `claude plugin details` reports them as
"harness-only".

### The manifest cannot carry permissions

`plugin.json` has a `settings` key, but only `agent` and `subagentStatusLine` take
effect; everything else is dropped at load. So `permissions.deny` / `ask` **cannot**
ship in the plugin. `scripts/block-merge.sh` is the enforcement layer, and
`templates/settings.json` exists for `/sdlc:bootstrap` to merge into the product repo.

Remote branch protection remains the actual control. The hook is a backstop.

### Unverified: how the root skill is invoked

The root `SKILL.md` is named `sdlc` inside plugin `sdlc`, and `claude plugin details`
confirms a skill called `sdlc` loads. Whether a user types **`/sdlc` or `/sdlc:sdlc`**
was not settled — confirming it needs an interactive session with the workspace
trusted, which the setup work couldn't do.

`README.md` and `SKILL.md` both currently say `/sdlc`. **Check this on first real use**
and correct both if it's the namespaced form. Automatic invocation is unaffected either
way; only the typed command is in doubt.

### Two traps

- **No `CLAUDE.md` at the plugin root.** It isn't loaded as context and
  `claude plugin validate` warns about it. Instructions belong in a skill.
- **No `": "` in a skill's `description`.** It breaks the YAML scalar and the
  frontmatter silently loads empty. `claude plugin validate` catches it — always run
  it after editing frontmatter.

### `claude plugin eval` is not in v2.1.177

The subcommand does not exist on this version — `claude plugin eval .` returns
`error: unknown command 'eval'`. The suite under `evals/` is written to the documented
format but **has never been executed**, so its graders are unverified.

Two consequences:

- Upgrade Claude Code before relying on evals as a release gate, and expect to fix
  graders on the first real run.
- Until then, a retro report must state that evals could not be run. `/sdlc:retro`
  already instructs this, and `templates/retro.md` has a section for it. A proposal that
  implies evals passed when the command was unavailable is worse than one that admits
  the gap.

### Context cost

Ten skills cost roughly **700 always-on tokens** in every session where the plugin is
enabled, whether or not the process is used. `claude plugin details sdlc` gives the
current figure. Worth re-checking before adding more skills.
