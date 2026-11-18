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
# The step "Push the branch and open the pull request" of the Sync upstream
# workflow.  Pushes $BRANCH, and opens its pull request (or updates the text
# of the open one), from the files of merge-upstream.sh and
# commit-updates.sh in $RUNNER_TEMP.  Sets the step outputs "changed" (true
# when it pushed) and "pr" (the number of the pull request).  Needs GH_TOKEN
# and RUN_URL (the page of the workflow run).

set -e -o pipefail
set -x

cd "$(dirname "$0")/.."

tree=$(git rev-parse 'HEAD^{tree}')
if [[ "$tree" == "$(git rev-parse 'main^{tree}')" ]]; then
  echo "Nothing new."
  echo "changed=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

# The same files as the branch of an earlier run: no new push, build, or
# comment.
if git fetch origin "$BRANCH" &&
    [[ "$tree" == "$(git rev-parse 'FETCH_HEAD^{tree}')" ]]; then
  echo "The branch $BRANCH has these changes already."
  echo "changed=false" >> "$GITHUB_OUTPUT"
  exit 0
fi

gh auth setup-git
git push --force origin "$BRANCH"

{
  echo "Made by the Sync upstream workflow: $RUN_URL"
  echo
  echo "## Changes of the Shaka Project"
  echo
  cat "$RUNNER_TEMP/upstream.txt"
  [[ -s "$RUNNER_TEMP/upstream.txt" ]] || echo "None."
  echo
  echo "## Versions that Dez moves"
  echo
  sed -e 's/^/- /' "$RUNNER_TEMP/pin.txt"
  cat "$RUNNER_TEMP/libraries.txt"
  [[ -s "$RUNNER_TEMP/pin.txt" || -s "$RUNNER_TEMP/libraries.txt" ]] || echo "None."
  echo
  echo "The same workflow run builds all targets from this branch, and adds its result as a comment."
  echo "After the merge, tag a release by hand (README, \"Tag names\")."
} > "$RUNNER_TEMP/body.md"

pr=$(gh pr list --head "$BRANCH" --state open --json number --jq '.[0].number // empty')
if [[ -z "$pr" ]]; then
  url=$(gh pr create --base main --head "$BRANCH" \
      --title "Sync with the Shaka Project and update libraries" \
      --body-file "$RUNNER_TEMP/body.md")
  pr="${url##*/}"
else
  gh pr edit "$pr" --body-file "$RUNNER_TEMP/body.md"
fi

echo "pr=$pr" >> "$GITHUB_OUTPUT"
echo "changed=true" >> "$GITHUB_OUTPUT"
