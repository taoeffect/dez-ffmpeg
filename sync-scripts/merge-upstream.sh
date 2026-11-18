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
# The step "Merge the changes of the Shaka Project" of the Sync upstream
# workflow.  Makes the branch $BRANCH from main, and merges the main branch
# of $UPSTREAM_URL into it; merge-versions.sh solves a conflict of the
# ffmpeg pin alone.  Writes the commits of the Shaka Project that main does
# not have to $RUNNER_TEMP/upstream.txt, and the line of merge-versions.sh,
# if any, to $RUNNER_TEMP/pin.txt.  Sets the step output "problem" to
# "conflict" for any other conflict (the merge is undone), or to
# "workflows" when the merge changes .github/workflows/.

set -e -o pipefail
set -x

cd "$(dirname "$0")/.."

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git switch -C "$BRANCH" main
touch "$RUNNER_TEMP/pin.txt"

git fetch "$UPSTREAM_URL" main
git log --no-merges --format='- %s (%h)' HEAD..FETCH_HEAD > "$RUNNER_TEMP/upstream.txt"

if ! git merge --no-edit -m "Merge the changes of the Shaka Project" FETCH_HEAD; then
  if [[ "$(git diff --name-only --diff-filter=U)" == "versions.txt" ]] &&
      sync-scripts/merge-versions.sh > "$RUNNER_TEMP/pin.txt"; then
    git commit --no-edit
  else
    git merge --abort
    echo "problem=conflict" >> "$GITHUB_OUTPUT"
    exit 0
  fi
fi

if [[ -n "$(git diff --name-only main HEAD -- .github/workflows)" ]]; then
  echo "problem=workflows" >> "$GITHUB_OUTPUT"
fi
