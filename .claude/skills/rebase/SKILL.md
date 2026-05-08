---
name: rebase
description: Rebase a work-in-progress or completed branch onto a new base, ensuring the rebased changes still satisfy their original spec, comply with the (possibly updated) architecture, conventions, and invariants of the new base, and introduce no regressions. Use when the user says "rebase this branch on X", "rebase my work on master", "move these commits onto the new base", or otherwise asks to migrate a set of commits onto a different base than they were authored against.
---

# Rebase a branch onto a new base

The point of this skill is **not** `git rebase`. Git can replay commits; it cannot tell you whether the replayed solution still makes sense. This skill is about the *thinking* around a rebase: re-validating the rebased work against a moved-on codebase, then doing the mechanical rebase carefully.

## When to invoke

- "Rebase `<branch>` on `<new-base>`" / "rebase my WIP onto master"
- "I started this work two weeks ago, can you rebase it on the latest master"
- After a long-lived feature branch — before merging — to verify it still aligns with current architecture, specs, and conventions
- Any time commits authored against an older base must land on a newer one and the user cares about correctness, not just merge-conflict resolution

Do **not** invoke for trivial fast-forward rebases with no semantic delta (e.g. base advanced by one unrelated commit) — just `git rebase` directly.

## Inputs to establish up front

- `curr` — the branch / commit being rebased (default: current branch `HEAD`)
- `old_base` — the base `curr` was originally branched from (default: merge-base of `curr` and `new_base`)
- `new_base` — the target base (default: `master` / `main`, confirm with user)

If any of these are ambiguous, **ask** before proceeding. Wrong base picks silently invalidate the entire analysis.

## Workflow

### 1. Establish the three points

```bash
git rev-parse HEAD                              # curr
git merge-base <curr> <new_base>                # old_base (likely)
git rev-parse <new_base>                        # new_base
```

State all three back to the user before continuing. If `old_base == new_base`, nothing to do — say so and stop.

### 2. Inventory `curr`'s changes

```bash
git log --oneline <old_base>..<curr>
git diff --stat <old_base>..<curr>
```

For each commit on `curr`, capture: subject, intent, files touched, and any spec/invariant it's claimed against. This is the "what we're trying to preserve" baseline.

### 3. Inventory the delta: `delta = new_base - old_base`

```bash
git log --oneline <old_base>..<new_base>
git diff --stat <old_base>..<new_base>
```

Pay particular attention to:

- **Product specs** (e.g. `docs/product-spec/`, `docs/invariants.md`) — requirements may have changed
- **Architecture docs** (`docs/architecture.md`, `AGENTS.md`, component-level `AGENTS.md`) — boundaries may have moved
- **Code conventions / lint rules / `.editorconfig` / formatter configs** — style may have shifted
- **Schema / migration files** — data shape may have changed
- **Public APIs and shared utilities** — signatures `curr` depends on may have changed
- **Files `curr` touches** — direct conflict surface

For non-trivial deltas, delegate the survey to an Explore agent rather than reading every commit by hand.

### 4. Cross-impact analysis

For each piece of `curr`'s change, classify against `delta`:

| Classification | Meaning | Action |
|---|---|---|
| **Untouched** | `delta` did not modify the surface `curr` relies on | Replay as-is |
| **Adjusted** | `delta` modified a dependency; `curr` still applies but needs edits | Plan the edits |
| **Extended** | `delta` added new surface `curr` should also cover (new caller, new channel, new spec) | Plan the extension |
| **Obsolete** | `delta` removed the code `curr` modifies, or already solves the problem | Drop the commit; confirm with user |
| **Conflicting** | `delta` introduces requirements that contradict `curr`'s solution | Stop; escalate |

Also check: has the **original problem** been (partially) solved on `new_base` already? If yes, much of `curr` may be redundant.

### 5. Risk gate

If any of the following is true, **stop and discuss with the user before touching code**:

- A commit on `curr` is classified **Conflicting**
- Architecture in `delta` invalidates the approach `curr` took
- The original problem is already solved differently on `new_base`
- The rebased solution would violate an invariant added in `delta` (e.g. data privacy, isolation, channel rules)

Surface these as a short summary with the inverted-pyramid principle: headline first ("rebase is risky because…"), then the specific conflicts, then options.

### 6. Identify gaps

Enumerate, with file paths:

- New code in `delta` the rebased solution must be **extended to** (e.g. a new channel/handler that needs the same fix)
- Old code removed in `delta` whose modifications in `curr` are **no longer needed**
- Existing code modified in `delta` whose modifications in `curr` need **adjustment**
- Existing code unmodified in `delta` that `curr` can keep **as-is**

### 7. Derisk: validate assumptions

Before committing to the plan, cross-check the riskiest assumptions:

- Re-read the relevant product spec on `new_base` (not on `old_base` — they may differ)
- Re-read the relevant architecture sections on `new_base`
- Re-read invariants files on `new_base`
- For any "I assume X is still true" — verify by reading current code

For non-trivial rebases, run three explicit validation passes (mirroring `feedback_plan_validation_passes`): assumption pass, spec+architecture pass, edge-case pass.

### 8. Present the plan

Before executing, show:

- Per-commit plan: replay / replay-with-edits / drop / split / new-commit
- For each "replay-with-edits" or "new-commit": the specific files and the specific changes
- Open questions, if any — ask now, not mid-rebase

Wait for user approval unless in auto mode and the rebase is low-risk.

### 9. Execute commit-by-commit

Prefer an interactive-style approach where each logical commit is handled independently:

- Replay or recreate the commit (resolve conflicts thoughtfully — never `-X theirs`/`-X ours` blindly)
- Apply the planned adjustments **in the same commit** if they're part of preserving the original intent; **in a separate commit** if they're a new fix discovered during rebase (per the "split move and bug-fix commits" rule)
- After each commit: lint and run unit tests for the affected area
- For risky commits (touching shared code, schemas, agent context, auth, billing): also do an e2e check or ask the user for one

Never `--no-verify` to push past hook failures. Fix the underlying issue.

### 10. Final verification

After all commits land:

- Full lint pass on affected components (`just lint` or component-specific)
- Full unit test pass (`just test` or component-specific)
- E2E sanity for the user-visible behavior the original branch was supposed to deliver
- Re-read the original spec/PR description (if any): does the rebased branch still satisfy every acceptance criterion?
- Check for regressions in the surfaces `delta` touched but `curr` did not — those are the easiest to break and the easiest to miss

### 11. Report

Summarize for the user, inverted-pyramid:

- Headline: rebase succeeded / succeeded with adjustments / blocked
- Per-commit outcome (replayed / edited / dropped / new)
- Any spec or invariant deviations resolved, with the resolution
- Anything the user should still verify manually

## Anti-patterns

- **Treating rebase as a merge-conflict exercise.** Conflict markers are the visible 10%; semantic drift is the invisible 90%.
- **Replaying without re-reading the spec.** The spec on `old_base` is not the spec you're shipping against.
- **Bundling rebase fixes into the original commit when they're really new bug fixes.** Split them.
- **Skipping lint/tests "because rebase didn't touch logic."** Rebase always touches logic — that's the whole point of this skill.
- **Forcing through a Conflicting classification without surfacing it.** Stop and talk to the user.
