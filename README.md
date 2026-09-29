# spec-sdlc-simple

A spec-driven SDLC you can drop into any repo. Eight stages, one named artifact per
stage, committed to version control. The artifact is the handoff.

Based on Anthropic's [AI-Native SDLC Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook).

**Start here: [`SPEC_SDLC.md`](SPEC_SDLC.md)** — the whole process in one
self-contained file.

---

## The idea

The bottleneck in AI-assisted development is no longer writing code. It's knowing
whether the code being written is the right code. So intent and requirements move to
the front, into durable files, and each stage can't start until the previous one's
artifact exists.

| # | Stage | Artifact |
|---|-------|----------|
| 1 | Intent | `intent.md` — the problem, before anyone solutions it |
| 2 | Requirements | `spec.md` — functional, security, governance, stack, testing, local dev, CI/CD |
| 3 | Design | `design.md` — flows, screens, every state, copy, accessibility |
| 4 | Plan | `BUILD_PLAN.md` (phased checklist) + `build/NN-*.md` (how the code gets written) |
| 5 | Build | Code + ticked checkboxes, self-verified per phase |
| 6 | Test | `TEST_REPORT.md` — evidence per acceptance criterion |
| 7 | Deploy | A pull request. **The AI never merges it.** |
| 8 | Maintain | Production feedback becomes a new `intent.md` |

Three size tracks keep it proportionate — a typo fix doesn't get an eight-stage pass.

---

## Install

### Minimum — one file

```bash
curl -O https://raw.githubusercontent.com/wodutoit/spec-sdlc-simple/main/SPEC_SDLC.md
```

That's genuinely enough. Point your agent at it and the process runs. Add a line to
your `CLAUDE.md`:

```markdown
## Process
This repo follows `SPEC_SDLC.md`. The AI never merges a pull request.
```

### Recommended — file + skills

The skills make each stage trigger without you having to ask for it. Claude Code
loads `.claude/skills/` from the repo it's running in, so they have to be **copied
into** your project — referencing this repo from elsewhere won't load them.

macOS / Linux:

```bash
git clone --depth 1 https://github.com/wodutoit/spec-sdlc-simple /tmp/spec-sdlc
cp /tmp/spec-sdlc/SPEC_SDLC.md .
mkdir -p .claude/skills
cp -r /tmp/spec-sdlc/.claude/skills/* .claude/skills/
cp -r /tmp/spec-sdlc/templates .
```

Windows PowerShell:

```powershell
$src = Join-Path $env:TEMP 'spec-sdlc'
git clone --depth 1 https://github.com/wodutoit/spec-sdlc-simple $src
Copy-Item "$src\SPEC_SDLC.md" .
New-Item -ItemType Directory -Force .claude\skills | Out-Null
Copy-Item "$src\.claude\skills\*" .claude\skills\ -Recurse
Copy-Item "$src\templates" . -Recurse
```

Eight skills land: `spec-sdlc` (the router, which works out what stage you're in) plus
one per stage.

### Then make the merge rule real

`SPEC_SDLC.md` says the AI never merges. A markdown file is a suggestion an agent can
drift from. What actually binds it:

1. **Branch protection on `main`**, requiring a pull request and code-owner approval.
   This is the control — it holds regardless of which agent, which machine, or which
   settings file is loaded. Do this one at minimum.
2. **`templates/hooks/block-merge.sh`** — a `PreToolUse` hook that blocks merges,
   force pushes, protected-branch pushes and `--no-verify`, and tells the agent why.
   Copy to `.claude/hooks/`, then `chmod +x`. On Windows it runs under Git Bash, which
   ships with Git for Windows. This is the reliable local layer: it inspects the actual
   command string rather than relying on pattern matching.
3. **`templates/settings.json`** — merge into your `.claude/settings.json`. Denies the
   obvious merge commands and asks before commit, push and PR creation. Permission
   pattern syntax varies between Claude Code versions, so treat these entries as a
   convenience on top of the hook rather than the thing you depend on, and confirm
   they load cleanly in your version.

The `allow` list in `settings.json` is there so the process doesn't drown in prompts
on safe read-only git operations. Trim or extend it to match your repo's commands.

---

## What's in here

```
SPEC_SDLC.md                   The process. Self-contained. This is the deliverable.
README.md                      You are here.

.claude/skills/
  spec-sdlc/                   Router — works out the current stage, routes onward
  sdlc-intent/                 Stage 1
  sdlc-requirements/           Stage 2
  sdlc-design/                 Stage 3
  sdlc-plan/                   Stage 4
  sdlc-build/                  Stage 5
  sdlc-test/                   Stage 6
  sdlc-deploy/                 Stage 7

templates/
  intent.md                    Stage 1 artifact
  spec.md                      Stage 2 artifact — the 12-section checklist
  design.md                    Stage 3 artifact
  BUILD_PLAN.md                Stage 4 — phased checklist
  build-phase.md               Stage 4 — per-phase build detail
  TEST_REPORT.md               Stage 6 artifact
  REVIEW.md                    Review policy, for repo root
  CLAUDE.md                    Repo context skeleton, for repo root
  settings.json                Permissions + hook wiring
  hooks/block-merge.sh         The merge-blocking hook
```

---

## Using it

Once installed, this mostly runs itself:

- *"I want to add user invites"* → the router picks stage 1, interviews you, proposes
  a track, writes `intent.md`.
- *"what stage am I in?"* → the router reads `specs/` and tells you.
- *"let's build it"* → stage 5 works one phase at a time and won't advance until the
  phase's done-test passes.
- *"ship it"* → stage 7 asks before committing, asks before the PR, opens the PR, and
  stops.

You can also drive it directly: `/sdlc-requirements`, `/sdlc-plan`, and so on.

---

## Adopting it gradually

Don't switch all eight stages on at once. The stages are ordered by dependency and
Intent has no prerequisites, so:

1. `SPEC_SDLC.md` + one real `intent.md`. See how it feels.
2. `CLAUDE.md` — fastest payoff of anything here, and cheap.
3. Stage 2 on your next real feature. This is where most of the value is.
4. Stage 4 — `BUILD_PLAN.md` committed *before* the code.
5. Branch protection and the merge rule.
6. Stages 6 and 7, then `REVIEW.md`.
7. Stage 8 once you have monitoring worth reacting to.

**Working:** less rework after build starts, higher first-pass merge rate, fewer
"that's not what I meant" moments.

**Failing:** artifacts written after the code as paperwork, everything tracked L,
everything tracked S, specs nobody reads. All the same failure — the artifact stopped
being the handoff and became a formality.

---

## Notes

- The playbook collapses requirements and design into one stage; this splits them into
  Requirements (2), Design (3), and Plan (4), because in practice they have different
  participants and fail in different ways. Artifact names match the playbook where
  they map, so the two are readable side by side.
- Nothing here is tool-specific except `.claude/skills/` and `settings.json`.
  `SPEC_SDLC.md` works with any agent that can read a file.
- Organizations with their own security standards: stage 2 is where that check
  belongs — before code exists, not at review time. `spec.md` §3 and §4 have a line
  for the reference.

## Licence

MIT.
