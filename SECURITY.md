# Security Policy

This is the default security policy for Immersive Fusion's open source repositories.
Some projects add their own scope notes on top of it; where a repository has its own
`SECURITY.md`, that one wins.

## Reporting a vulnerability

Please report security issues privately, not in a public issue.

- **Preferred:** open a private report from the **Security** tab of the repository
  where you found the issue, using "Report a vulnerability".
- **Email:** security@immersivefusion.com

Include what you found, how to reproduce it, and the impact you expect. We aim to
acknowledge within a few business days and will keep you updated as we work on a fix.
Please give us reasonable time to remediate before any public disclosure.

## What helps

A report we can reproduce is worth far more than one we cannot. Where you can, include:

- The repository and the version, tag, or commit you tested.
- The smallest set of steps that reproduces it.
- What an attacker gets out of it. "This crashes" and "this reads another tenant's
  data" are very different findings and we would rather not guess which you mean.

## Generally out of scope

- Vulnerabilities in third-party services that an operator points one of our tools at.
- Issues that require an operator to supply a deliberately hostile configuration,
  environment, or credential.
- Findings from automated scanners with no demonstrated impact.

None of these are hard rules. If you think you have something real that sits in one of
those categories, send it anyway and say why.

## Credit

We are happy to credit reporters by name or handle in the advisory and release notes.
Tell us how you would like to be named, or that you would rather not be.
