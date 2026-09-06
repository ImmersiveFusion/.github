# New repository baseline

What every Immersive Fusion repository gets, and how to apply it to a new one.

Run this on the day the repository is created, before the first real pull request.
Retrofitting is harder: rules that arrive after a history exists have to be argued
with rather than assumed.

```bash
scripts/new-repo-baseline.sh <repo>                 # no CI yet
scripts/new-repo-baseline.sh <repo> ci              # once CI exists
scripts/new-repo-baseline.sh <repo> "API build and tests" "SPA build"
```

The script is idempotent, so re-running it is the normal way to use it: run it bare
at creation, then again with the check names once CI is green. `DRY_RUN=1` prints
what it would send without sending it.

## What the script sets

| Setting | Value | Why |
|---|---|---|
| Secret scanning | enabled | Free on public repositories. |
| Push protection | enabled | The half that stops a secret landing, rather than reporting it after the fact. |
| Dependabot alerts | enabled | |
| `GITHUB_TOKEN` default | read-only | Workflows that need more declare their own `permissions:` block. |
| Actions approving PRs | off | An Action that can approve is an Action that can satisfy the one-approval rule. |
| Signed commits | required | |
| Linear history | required | |
| Pull request | required, 1 approval | Plus code owner review, stale-approval dismissal, last-push approval, thread resolution. |
| Merge methods | squash, rebase | No merge commits, so linear history holds. |
| Required checks | the contexts you pass | Without these CI runs and gates nothing. |
| Tag rules | creation, update, deletion, non-fast-forward | Restricted to repository admins. |

Two of those are worth expanding on.

**Required status checks are the one people forget.** A repository can have CI on
every pull request, green every time, and still merge a red build, because running a
check and requiring a check are different settings. Seven of our eight repositories
were in exactly that state until this baseline existed. Pass the check contexts to
the script, and confirm afterwards that the names match what CI actually reports:
they are the check run names, not the workflow file names.

**Tag rules cover every tag, not just `v*`.** Some of our release workflows also
trigger on a bare-number tag such as `0.7.4`, so a `v*` pattern would leave the
release path open to anyone with write access. Repository admins bypass the rule, so
releases still work for the people who cut them.

## What the script cannot do

**`.github/CODEOWNERS` has to arrive in a pull request.** Add it in the first one:

```
* @ETWOYA @dankoverride
```

This is not optional. The ruleset sets `require_code_owner_review`, and with no
CODEOWNERS file no path has an owner, so the requirement never fires. It reads as a
gate in the settings UI and enforces nothing. Five of our repositories sat in that
state.

**CI workflows** are per-project. Give every workflow an explicit `permissions:`
block, since the token now defaults to read-only. Release workflows need
`contents: write`.

## What the repository inherits

`CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md` and the issue
and pull request templates all live in this repository and are served automatically
to any repository in the organization that does not publish its own. A new repository
needs none of them.

Add a local `CONTRIBUTING.md` only when the project needs its own build and test
instructions. If you do, it **replaces** the organization default rather than adding
to it, so carry over the commit signing section. That section exists because an
outside contributor once had a finished, approved pull request blocked by an unsigned
commit that nothing in the repository had warned them about.

A new repository does still need its own `LICENSE` and `README.md`.

## A better version of this

The script is a workaround. An organization-level ruleset applied to all
repositories would enforce the branch and tag rules on every repository including
ones created next year, with nobody having to remember to run anything. That needs
the `admin:org` scope:

```bash
gh auth refresh -h github.com -s admin:org
```

Until then, this script plus this checklist is the mechanism, which means it depends
on someone running it. If a repository is missing the baseline, that is the reason.
