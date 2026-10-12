# Impact tool

What a change touches — its blast radius — is the most expensive thing for an AI to work
out by reading, and the easiest to get wrong. A tool that answers it deterministically is
cheaper, repeatable, and runs in a pipeline. This process **recommends one in every
repo**, and works without one (see [Without a tool](#without-a-tool)).

## What the tool must be able to do

| Capability | Why |
|---|---|
| Given a file or symbol, list its **callers, importers and references** | the core of a blast radius |
| Given a set of changed files, list the **affected modules or targets** | what the pipeline needs |
| **Deterministic, machine-readable** output (JSON, SARIF, plain lines) | so a plan can record it and a pipeline can compare it |
| Runs **headless** from a command line | so it runs in CI, not just on a laptop |
| Scoped to the paths you give it | a whole-repo dump costs more than reading |
| **Version-pinned** and approved by your organisation | it runs on your code; treat it as a dependency |

It reports what is *statically connected*. It does not see reflection, names built from
strings, config-driven wiring, schema or SQL coupling, or callers in other repos. Those are
the **blind spots**, and they are what a code-knowledge note records. The tool plus the
blind-spot checks is the whole impact check.

## Examples

Illustrations by ecosystem, **not endorsements and not verified for your stack**. Check
that the tool exists, is maintained, and does what you need before adopting it.

| Ecosystem | Examples |
|---|---|
| Any, across repos | Sourcegraph code intelligence; CodeQL queries |
| JavaScript / TypeScript | dependency-cruiser; madge |
| JVM | `jdeps`; your build tool's dependency report |
| Monorepos with a build graph | Bazel `rdeps` queries; Nx `affected` |
| Anything with a language server | "find references" through the server |

If your organisation restricts which tools or MCP servers may be used, use the approved
ones. A code-graph server is fine if it meets the table above and is on the allowlist.

## Declaring it

Bootstrap records it in the committed lock, `.claude/spec-sdlc.json`:

```json
"config": {
  "impactTool": {
    "command": "<exact command, with {paths} where changed paths go>",
    "ciReport": "<where the pipeline publishes its report: job name, artifact or URL>"
  }
}
```

Both are optional. Never guess a command: ask, or leave it null.

## How stage 4 uses it

For every file or symbol the plan creates, modifies or deletes:

1. Run `impactTool.command` with `{paths}` filled in. Record the command, the revision and
   what it returned.
2. Search the **blind spots** the area's note lists, plus the general ones above.
3. Record both under **Impact check** in `BUILD_PLAN.md`.

Live findings may **raise** the track or review tier. Nothing — not this tool, not a note —
may lower it. "No dependents found" is reported as *nothing found by this tool and these
searches*, never as *there is nothing*.

## Without a tool

Fall back to live search for references, importers and callers. Mark the Impact check
**`tool-less`**: lower confidence, and a reviewer should know. Do not present it as
equivalent. The retro counts tool-less plans, so a repo that keeps running without a tool
gets asked why.

## In the pipeline

A CI job runs **the same tool** on the pull request's changed files and publishes the
report. The plan's Impact check is the *prediction*; the pipeline report is the
*measurement* on the diff that actually shipped.

- **The job runs the deterministic tool. It never runs an AI agent.**
- Stage 7 links the report in the PR description.
- The review's plan/diff pass compares them. A dependent in the report that the plan did
  not list is a finding.

Placeholder job — adapt it; do not paste it as is. Pin every action to a full commit SHA.
Values from the event go through environment variables, never interpolated into a shell
command, because a branch name is untrusted input.

```yaml
name: impact-report
on: pull_request
permissions:
  contents: read
jobs:
  impact:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<pinned-commit-sha>
        with:
          fetch-depth: 0
      - name: List changed files
        env:
          BASE_REF: ${{ github.base_ref }}
        run: git diff --name-only "origin/${BASE_REF}...HEAD" > changed.txt
      - name: Run the impact tool
        run: <your impact command> --input changed.txt --output impact-report.json
      - uses: actions/upload-artifact@<pinned-commit-sha>
        with:
          name: impact-report
          path: impact-report.json
```

## What the comparison means

| Plan said | Report found | Meaning |
|---|---|---|
| X depends on this | X depends on this | the plan was right |
| nothing for Y | Y depends on this | **the plan under-predicted** — a finding; usually a blind spot missing from a note |
| Z depends on this | nothing for Z | the plan over-predicted; harmless, but worth a look |

A plan that under-predicts the same area repeatedly is a retro finding: the area's note is
missing a blind spot.
