#!/bin/bash

# Copyright 2026 The Dez Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Added for Dez.
# The step "Open an issue for a merge by hand" of the Sync upstream
# workflow.  Opens one issue that tells why the merge needs a person
# ($PROBLEM: "conflict" or "workflows", from merge-upstream.sh) and how to
# do it, unless that issue is open already.  Needs GH_TOKEN and
# UPSTREAM_URL.

set -e -o pipefail
set -x

title="Sync upstream: merge the Shaka Project's changes by hand"
open=$(gh issue list --state open --search "\"$title\" in:title" --json number --jq 'length')
if [[ "$open" != "0" ]]; then
  echo "The issue is open already."
  exit 0
fi

if [[ "$PROBLEM" == "conflict" ]]; then
  reason="The changes of the Shaka Project do not merge with the changes of Dez: there is a conflict that merge-versions.sh does not solve."
else
  reason="The changes of the Shaka Project change files in .github/workflows/, and the token of a workflow cannot push them."
fi

{
  echo "$reason"
  echo
  echo "Commits of the Shaka Project that main does not have:"
  echo
  cat "$RUNNER_TEMP/upstream.txt"
  echo
  echo "To merge them by hand:"
  echo
  echo '```sh'
  echo "git switch main && git pull"
  echo "git fetch $UPSTREAM_URL main"
  echo "git merge FETCH_HEAD    # fix the conflicts, if any, then commit"
  echo "                        # (sync-scripts/merge-versions.sh fixes one of the ffmpeg pin)"
  echo "sync-scripts/update-versions.sh    # then commit its changes, if any"
  echo "git push origin main"
  echo '```'
} > "$RUNNER_TEMP/issue.md"

gh issue create --title "$title" --body-file "$RUNNER_TEMP/issue.md"
