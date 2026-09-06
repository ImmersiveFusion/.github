#!/usr/bin/env bash
#
# Apply the Immersive Fusion repository baseline to one repository.
#
#   ./new-repo-baseline.sh <repo> [check-context ...]
#
#   ./new-repo-baseline.sh my-new-tool
#   ./new-repo-baseline.sh my-new-tool ci
#   ./new-repo-baseline.sh my-new-tool "API build and tests" "SPA build"
#
# Pass the check contexts once CI exists; re-run later to add them. The script is
# idempotent, so re-running it is the normal way to use it.
#
# Requires the gh CLI, authenticated with admin on the repository.
# Set DRY_RUN=1 to print what would be sent without sending it.
#
# What it deliberately does not do, because those need a pull request rather than
# an API call: add .github/CODEOWNERS, and add CI workflows. See
# NEW-REPO-BASELINE.md for the full checklist.

set -euo pipefail

ORG=ImmersiveFusion
REPO=${1:?usage: new-repo-baseline.sh <repo> [check-context ...]}
shift || true
CHECKS=("$@")
DRY_RUN=${DRY_RUN:-0}

say() { printf '  %-32s %s\n' "$1" "$2"; }
send() { # send <description> <gh api args...>  (reads body on stdin)
  local desc=$1; shift
  if [ "$DRY_RUN" = "1" ]; then
    echo "  DRY RUN $desc: gh api $*"; cat >/dev/null
  else
    gh api "$@" --input - >/dev/null
  fi
}

echo "Applying baseline to $ORG/$REPO"

# 1. Secret scanning and push protection. Both are free on public repositories.
#    Push protection is the one that stops a secret before it lands, rather than
#    telling you about it afterwards.
send "security" -X PATCH "repos/$ORG/$REPO" <<'JSON'
{"security_and_analysis":{"secret_scanning":{"status":"enabled"},
                          "secret_scanning_push_protection":{"status":"enabled"}}}
JSON
say "secret scanning" "enabled"
say "push protection" "enabled"

# 2. Dependabot alerts.
if [ "$DRY_RUN" != "1" ]; then gh api -X PUT "repos/$ORG/$REPO/vulnerability-alerts" >/dev/null; fi
say "dependabot alerts" "enabled"

# 3. GITHUB_TOKEN defaults to read-only, and Actions may not approve pull
#    requests. Workflows needing more declare their own permissions block. An
#    Action that can approve is an Action that can satisfy the review rule.
send "actions" -X PUT "repos/$ORG/$REPO/actions/permissions/workflow" <<'JSON'
{"default_workflow_permissions":"read","can_approve_pull_request_reviews":false}
JSON
say "actions token" "read-only, cannot approve PRs"

# 4. The branch ruleset on the default branch.
CHECKS_RULE=""
if [ ${#CHECKS[@]} -gt 0 ]; then
  CTX=$(printf '{"context":"%s","integration_id":15368},' "${CHECKS[@]}")
  CHECKS_RULE=",{\"type\":\"required_status_checks\",\"parameters\":{\"do_not_enforce_on_create\":false,\"strict_required_status_checks_policy\":true,\"required_status_checks\":[${CTX%,}]}}"
fi

BODY=$(cat <<JSON
{"name":"default","target":"branch","enforcement":"active",
 "bypass_actors":[{"actor_id":1,"actor_type":"OrganizationAdmin","bypass_mode":"always"}],
 "conditions":{"ref_name":{"include":["~DEFAULT_BRANCH"],"exclude":[]}},
 "rules":[{"type":"deletion"},{"type":"non_fast_forward"},{"type":"required_linear_history"},
          {"type":"required_signatures"},
          {"type":"pull_request","parameters":{"required_approving_review_count":1,
            "dismiss_stale_reviews_on_push":true,"require_code_owner_review":true,
            "require_last_push_approval":true,"required_review_thread_resolution":true,
            "require_extra_approval_for_unattributed_changes":true,"required_reviewers":[],
            "dismissal_restriction":{"enabled":false,"allowed_actors":[]},
            "allowed_merge_methods":["squash","rebase"]}}$CHECKS_RULE]}
JSON
)

EXISTING=$(gh api "repos/$ORG/$REPO/rulesets" --jq '.[]|select(.target=="branch" and .name=="default")|.id' 2>/dev/null || true)
# A failed call prints an error body on stdout, so only trust a bare number here.
[[ "$EXISTING" =~ ^[0-9]+$ ]] || EXISTING=""
if [ -n "$EXISTING" ]; then
  printf '%s' "$BODY" | send "branch ruleset" -X PUT "repos/$ORG/$REPO/rulesets/$EXISTING"
  say "branch ruleset" "updated (id $EXISTING)"
else
  printf '%s' "$BODY" | send "branch ruleset" -X POST "repos/$ORG/$REPO/rulesets"
  say "branch ruleset" "created"
fi

# 5. Tag ruleset. It only bites where a pushed tag ships a release, but it is
#    harmless everywhere else, so it belongs in the baseline rather than being a
#    decision someone has to remember to make. It covers every tag rather than
#    just v*, because some release workflows also trigger on a bare-number tag.
if gh api "repos/$ORG/$REPO/rulesets" --jq '.[]|select(.target=="tag")|.id' 2>/dev/null | grep -qE '^[0-9]+$'; then
  say "tag ruleset" "already present, left alone"
else
  send "tag ruleset" -X POST "repos/$ORG/$REPO/rulesets" <<'JSON'
{"name":"release-tags","target":"tag","enforcement":"active",
 "bypass_actors":[{"actor_id":5,"actor_type":"RepositoryRole","bypass_mode":"always"},
                  {"actor_id":1,"actor_type":"OrganizationAdmin","bypass_mode":"always"}],
 "conditions":{"ref_name":{"include":["refs/tags/*"],"exclude":[]}},
 "rules":[{"type":"creation"},{"type":"update"},{"type":"deletion"},{"type":"non_fast_forward"}]}
JSON
  say "tag ruleset" "created"
fi

echo
echo "Still to do by hand, in a pull request:"
echo "  - .github/CODEOWNERS  ->  * @ETWOYA @dankoverride"
echo "    Without it, require_code_owner_review is inert: it reads as a gate in the"
echo "    settings UI and enforces nothing."
if [ ${#CHECKS[@]} -eq 0 ]; then
  echo "  - No required status checks were set. Once CI exists, re-run:"
  echo "      ./new-repo-baseline.sh $REPO <check-name>"
fi
echo "  - Confirm LICENSE and README exist."
echo "  - CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md, SUPPORT.md and the issue"
echo "    and pull request templates are inherited from this repository. Add a local"
echo "    CONTRIBUTING.md only if the project needs its own build and test guidance,"
echo "    and carry over the commit signing section if you do."
