# Eval suite

Regression guard for the process. A skill edit changes behaviour in every repo running
this plugin, so a change advisory board needs evidence that existing behaviour still
holds — these cases are that evidence.

```bash
claude plugin eval .                      # whole suite
claude plugin eval . --tag smoke          # the fast subset
claude plugin eval . --case deploy-refuses-to-merge --runs 1 --ablation none
```

> **Requires a newer Claude Code than v2.1.177**, where `claude plugin eval` does not
> exist (`error: unknown command 'eval'`). These cases are written to the documented
> format but have **not been executed**, so treat the graders as unverified until a
> first successful run — a grader can be well-formed and still assert the wrong thing.
>
> Until then, a retro must say plainly in its report that evals could not be run, and
> the board decides whether to accept the change without that evidence. Do not let a
> proposal imply evals passed when the command was never available.

## What each case pins

| Case | Behaviour it protects |
|---|---|
| `vague-request-routes-to-intent` | A vague request starts at stage 1 and does not jump to code |
| `typo-fix-gets-track-s` | Small work stays cheap — track S, stages 2–4 skipped |
| `auth-change-forced-to-track-l` | Anything touching auth or sessions is forced to track L, however it's framed |
| `requirements-refuses-blank-sections` | Stage 2 never leaves a spec section blank |
| `build-refuses-to-weaken-test` | Stage 5 won't weaken a test to make it pass |
| `deploy-refuses-to-merge` | The AI never merges a pull request |

The last three are the ones that matter most: they protect the prohibitions, which are
the part of the process a model is most likely to drift away from under pressure from
the user.

## Adding a case

Required whenever a retro changes behaviour — a new case is part of that change, not a
follow-up. `claude plugin eval init --bare <case-name>` writes the skeleton.

Prefer a deterministic grader over a judge where one is possible. `never-called-merge.md`
asserts a tool was never invoked (`min: 0`, `max: 0`), which can't be talked around;
the `llm` graders beside it catch the softer failure of agreeing to do the wrong thing.

Each run starts in an **empty working directory**, so a case's prompt has to carry
everything it needs, or set the workspace up with a `case.yaml` `context` block.

## Prove the suite can fail

A suite that can't fail proves nothing. To check it still bites, delete the merge
prohibition from `skills/deploy/SKILL.md`, run `--case deploy-refuses-to-merge`,
confirm it goes red, then restore the file.

## Note

`results/` is written by each run and is gitignored. Eval runs call the model with your
credentials and count against usage.
