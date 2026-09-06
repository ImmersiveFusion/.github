# Contributing

The default contribution guide for Immersive Fusion's open source repositories. Where a
repository publishes its own `CONTRIBUTING.md`, that one wins for anything project
specific: how to build it, how to test it, what belongs in it. The branch rules on this
page still apply.

Pull requests are welcome on every one of these repositories. If you are planning
something substantial, open an issue first and check the direction, so nobody spends a
weekend on a change we cannot merge.

## Sign your commits

Most of our repositories require a verified signature on every commit that reaches
`main`. It is enforced by a rule on the branch rather than by a reviewer remembering to
look, so one unsigned commit anywhere in your branch blocks the merge even when the
change itself is finished and approved.

Set this up once and you will not think about it again.

**If you already push over SSH**, reuse that key:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

Then add that same public key to <https://github.com/settings/keys> a second time,
choosing **Signing key** rather than authentication key. One key can be registered as
both, but registering it only for authentication is not enough to make commits verify.

**If you prefer GPG**, [generate or import a key](https://docs.github.com/authentication/managing-commit-signature-verification/generating-a-new-gpg-key),
point git at it, and add the public key to that same settings page:

```bash
git config --global user.signingkey <YOUR_KEY_ID>
git config --global commit.gpgsign true
```

**Check it before you open the pull request:**

```bash
git log --show-signature -1
```

You want a good signature locally and a green **Verified** badge next to every commit in
the pull request's Commits tab.

### The trap worth knowing about

Commits made in the GitHub web editor are signed automatically, by GitHub. Commits
pushed from your own machine are not, unless you configured the above. So a branch can
start out fully verified, because the first edit happened in the browser, and then pick
up an unsigned commit the moment you fix something locally. The pull request looks fine
and the merge is blocked.

If that happens, it is one command to re-sign the branch and one to update the pull
request:

```bash
git rebase --exec 'git commit --amend --no-edit -S' main
git push --force-with-lease
```

For a single commit, `git commit --amend --no-edit -S` and the same push will do.

## Branch rules

`main` is protected on every repository. In practice:

- **Changes land through a pull request.** Nobody pushes to `main` directly, us included.
- **History stays linear.** Update your branch with `git rebase main`, not
  `git merge main`. Pull requests merge by squash or rebase, so a merge commit in your
  branch would not survive anyway.
- **A new push dismisses existing approvals.** If you push after a reviewer approves, it
  needs approving again, so batch your review fixes into one push where you can.
- **Review threads must be resolved before merge.** Reply and resolve, or say why you
  disagree. An open thread holds the merge.

The exact settings vary a little by repository:

| Repository | Signed commits | Linear history | Approvals | Merge methods | Required checks |
|---|---|---|---|---|---|
| `snowglobe`, `shoebox`, `sos-beacon`, `deepcube-mcp-server`, `.github` | Required | Required | 1 | Squash, rebase | none |
| `deepcube-docs` | Required | Required | 1 | Squash, rebase | `build-and-verify` |
| `academy-general`, `academy-kids` | Not enforced | Not enforced | 0 | Merge, squash, rebase | none |

Sign your commits on the academy repositories too. The rule is not switched on there
today, and nobody should have to remember which list a repository is on.

## The shape of a good pull request

1. Fork, and branch from `main`.
2. One logical change per pull request. Two ideas in one branch review slower than two
   branches.
3. Conventional commit messages (`feat:`, `fix:`, `docs:`, and so on).
4. Run what the repository's own guide tells you to run before pushing: its build, its
   tests, its linter. CI runs the same thing, and a red build is the first thing a
   reviewer sees.
5. Say how you tested it. "Added a test" and "ran it against a local collector and
   checked the spans" both work. "Did not test" is an acceptable answer; just say so.
6. Describe what changed and why. The why is the part a reviewer cannot reconstruct from
   the diff.

## Security issues

Do not open an issue. See [`SECURITY.md`](SECURITY.md), or mail
<security@immersivefusion.com>.

## Code of conduct

[`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) applies across these repositories: no
harassment, assume good faith, keep it about the work.

## Licence

These projects are Apache-2.0 unless the repository says otherwise. By contributing, you
agree that your contribution is licensed under that repository's licence.
