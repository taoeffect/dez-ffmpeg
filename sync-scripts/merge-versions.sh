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
# Solves a merge conflict of the ffmpeg pin in versions.txt.  Dez moves that
# pin (update-versions.sh), and so does the Shaka Project, on a line of its
# own block: a merge of its changes can stop there.  This script merges
# versions.txt again, with the ffmpeg pin of both sides, and of their base,
# set to the newer of the two pins, so that only the other changes of the
# file are merged.  It stages the result, and prints one line about the pin.
# It fails, and changes nothing, when the file has another conflict, or when
# a pin is not an FFmpeg version tag.
#
# Usage, in a merge that stopped with a conflict in versions.txt:
#   sync-scripts/merge-versions.sh && git commit --no-edit

set -e

cd "$(dirname "$0")/.."
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT

# The stages of a file in a merge: 1 is the base, 2 the current branch
# (Dez), and 3 the branch that is merged (the Shaka Project).
for stage in 1 2 3; do
  git show ":$stage:versions.txt" > "$dir/$stage"
done

pin() {
  grep '^ffmpeg:' "$1" | sed -e 's/.*: //'
}
ours=$(pin "$dir/2")
theirs=$(pin "$dir/3")
tag_pattern='^n[0-9]+\.[0-9]+(\.[0-9]+)?$'
if ! [[ "$ours" =~ $tag_pattern && "$theirs" =~ $tag_pattern ]]; then
  echo "The ffmpeg pins ($ours, $theirs) are not both FFmpeg version tags: merge versions.txt by hand." >&2
  exit 1
fi
newer=$(printf '%s\n%s\n' "$ours" "$theirs" | sort -V | tail -n 1)

for stage in 1 2 3; do
  sed -i.bak -e "s@^ffmpeg: .*@ffmpeg: $newer@" "$dir/$stage"
done

if ! git merge-file -q "$dir/2" "$dir/1" "$dir/3"; then
  echo "versions.txt has a conflict that is not the ffmpeg pin: merge it by hand." >&2
  exit 1
fi

cp "$dir/2" versions.txt
git add versions.txt
echo "ffmpeg: the Shaka Project has $theirs and Dez has $ours; the merge keeps $newer"
