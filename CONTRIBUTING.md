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
2. **Before** the release merge, in the release PR itself: bump `version` in
   `.claude-plugin/plugin.json`, and in `CHANGELOG.md` replace `unreleased` with the
   intended release date and put the release PR's link on the "Board decision" line.
3. Board approves → a human merges `main` into `release`.
4. Product repos pick it up with `/sdlc:bootstrap --relock`.

**Why step 2 comes before the merge.** A changelog edited *after* the release merge
lands on `main` only, so `release` — the branch product repos actually clone — keeps
saying `unreleased` until the next release. This happened with 0.2.0: it shipped
correctly but `release` still read "unreleased" and "pending". The cost is that the date
and PR link are written before the merge happens, so use the release PR's own number
and the date you expect to merge; if the board rejects it, the PR doesn't merge and the
entry never lands.

---

## Findings from setup — don't re-derive these

Verified against Claude Code **v2.1.177**, then partly re-verified on **v2.1.295**.
Re-check if a claim stops holding.

Note on the token figures below: the always-on estimate rose from ~711 to ~1,119
between those two versions with nine of ten skill files byte-identical, so treat the
absolute number as version-specific. The relative cost per skill is the useful part.

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

### `claude plugin eval` needs v2.1.295 — it is absent on v2.1.177

On v2.1.177, `claude plugin eval .` returns `error: unknown command 'eval'`. It works
from **v2.1.295**. Running it taught more than reading the docs did — see
[`evals/README.md`](evals/README.md) for the flags and the case-authoring pitfalls, and
note in particular that **Δ is the number that matters**, not the score.

All eight cases have now been run once; results and caveats are in `evals/README.md`.
Three things worth knowing before relying on them: a run that fails at startup still
exits 0 and prints plausible scores (check `turns`, not just the score); Δ is noisy at
one run, so use `--runs 3` for board evidence; and four cases show Δ 0.00, which makes
them regression guards rather than proof the skill adds value.

If the command is unavailable on a contributor's version, a retro report must say so
rather than implying evals passed. `/sdlc:retro` instructs this and
`templates/retro.md` has a section for it.

### Open: `evals/` overlaps the declared skills path

Every eval run warns:

> `evals/` overlaps the plugin's declared skills path `"./"` — discovery reads cases
> from a directory the plugin declares as a component location

The manifest sets `"skills": ["./"]` so the root `SKILL.md` loads as the router, which
makes the whole plugin root a component location — and `evals/` sits inside it.

**Not fixed**, because the fix is a separate change: move the router to
`skills/start/SKILL.md`, drop the `"skills": ["./"]` declaration, and let the default
`skills/` scan cover everything. That would also settle the `/sdlc` vs `/sdlc:sdlc`
question below, since the command would unambiguously become `/sdlc:start`. Worth doing
as its own proposal rather than bundled into an unrelated one.

### Expected: the marketplace install advisory

`claude plugin validate . --strict` passes but advises adding
`/plugin install sdlc --marketplace <owner>/<repo>` to the README. **Ignore it.** This
plugin is distributed as a gitignored clone, not through a marketplace — that is the
whole design. Don't "fix" it by adding an install line that doesn't work.

### Context cost

Ten skills cost roughly **700 always-on tokens** in every session where the plugin is
enabled, whether or not the process is used. `claude plugin details sdlc` gives the
current figure. Worth re-checking before adding more skills.
