# SHIP Workflow

SHIP is the submission phase. The agent repeats the work engineers did manually: final checks, TDD evidence review, security review, quality review, change summary, PR.

## Inspect Scope

```sh
git status --short --branch
git branch --show-current
git diff --stat <base>...HEAD
git diff --name-only <base>...HEAD
```

Use the correct base branch from the task, upstream, `origin/HEAD`, `origin/main`, or `origin/master`.

## Quality Checks

Run commands based on changed files and repo scripts. Prefer existing package scripts.

For this payments-api repository:

```sh
cd api && npm run build
cd api && npm run test:acceptance
cd validation-workbench && npm run build
```

Also run focused tests for modified modules when available.

## TDD Evidence

Confirm behavior changes followed traditional TDD:

- Red: identify the test that was added or changed first.
- Red: confirm the test initially failed for the expected behavior gap.
- Green: confirm production code was added to make that test pass.
- Refactor: confirm tests stayed green after cleanup.

If the branch history does not expose the red phase, inspect commits, test files, and final diff. In the PR, report available evidence honestly:

- `TDD: followed` when commit history or notes show red/green/refactor.
- `TDD: partially observable` when final tests exist but red-phase output is not available.
- `TDD: not applicable` for docs-only, mechanical, config-only, or explicitly untestable changes.
- `TDD: missing` when behavior changed without tests; block shipping unless the user accepts the risk.

## Security Checks

Inspect for secrets and unsafe local leakage:

```sh
git diff <base>...HEAD -- . ':(exclude)package-lock.json'
rg -n "aact_|AKIA|BEGIN (RSA|OPENSSH|PRIVATE) KEY|SECRET|TOKEN|PASSWORD|api[_-]?key" .
```

Check:

- No real provider tokens.
- No `.env` files or local credentials.
- No production endpoint switched to mock behavior by default.
- No broad CORS/auth relaxation unless intentionally scoped.
- No dependency changes without lockfile consistency.
- No generated build outputs accidentally included.

## Review

Review the patch for:

- Correct behavior against the requested requirement.
- Compatibility with existing DTOs, services, events, and runtime scripts.
- Error handling and idempotency.
- Test coverage for success and failure paths.
- Migration, deployment, or rollback concerns.

## PR Description

Use this structure:

```markdown
## Summary
- 

## TDD Evidence
- 

## Validation
- 

## Security and Quality
- 

## Risks / Notes
- 
```

Include exact commands and outcomes. Mention skipped checks with a concrete reason.

## Submit

If asked to submit the PR:

```sh
git push -u origin <branch>
gh pr create --base <base> --head <branch> --title "<title>" --body-file <body-file>
```

If `gh` is unavailable or authentication fails, leave the PR body ready and report the blocker.
