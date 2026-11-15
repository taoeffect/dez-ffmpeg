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
# Moves each library that Dez adds to versions.txt to its newest stable tag
# that is at least MIN_AGE_DAYS (default 14) days old.  A young release is
# skipped, as a broken or bad release is often found in its first days.
# Prints one line for each change.  The pins of the Shaka Project (ffmpeg,
# libvpx, ...) are not touched: they come from upstream.
#
# Usage: ./update-dez-libraries.sh

set -e

cd "$(dirname "$0")"
min_age_days="${MIN_AGE_DAYS:-14}"
now=$(date +%s)

# One line per library: the versions.txt key, the git URL (the same as in
# its build script), and the pattern of a stable tag.
libraries='
zlib https://github.com/madler/zlib ^v[0-9]+\.[0-9]+(\.[0-9]+)?$
freetype https://gitlab.freedesktop.org/freetype/freetype.git ^VER-[0-9]+-[0-9]+-[0-9]+$
harfbuzz https://github.com/harfbuzz/harfbuzz ^[0-9]+\.[0-9]+\.[0-9]+$
fribidi https://github.com/fribidi/fribidi ^v[0-9]+\.[0-9]+\.[0-9]+$
libass https://github.com/libass/libass ^[0-9]+\.[0-9]+\.[0-9]+$
'

# Prints the time of a tag in seconds since 1970: the tagger date of an
# annotated tag, else the commit date.
tag_time() {
  local url="$1" tag="$2" dir
  dir=$(mktemp -d)
  git -C "$dir" init -q
  git -C "$dir" fetch -q --depth 1 "$url" "refs/tags/$tag:refs/tags/$tag"
  local time
  time=$(git -C "$dir" for-each-ref --format='%(taggerdate:unix)' "refs/tags/$tag")
  if [[ -z "$time" ]]; then
    time=$(git -C "$dir" log -1 --format=%ct "refs/tags/$tag")
  fi
  rm -rf "$dir"
  echo "$time"
}

while read -r key url pattern; do
  [[ -z "$key" ]] && continue
  current=$(./get-version.sh "$key")
  tags=$(git ls-remote --tags --refs "$url" 2>/dev/null |
    sed -e 's@.*refs/tags/@@' | grep -E "$pattern" | sort -rV)

  # Newest first.  Stop at the current pin, or at a tag that sorts below it,
  # so that a pin never goes back.
  for tag in $tags; do
    if [[ "$tag" == "$current" ]] ||
        [[ "$(printf '%s\n%s\n' "$tag" "$current" | sort -V | tail -n 1)" == "$current" ]]; then
      break
    fi
    age_days=$(( (now - $(tag_time "$url" "$tag")) / 86400 ))
    if (( age_days >= min_age_days )); then
      sed -i.bak -e "s@^$key: .*@$key: $tag@" versions.txt
      rm -f versions.txt.bak
      echo "$key: $current -> $tag ($age_days days old)"
      break
    fi
  done
done <<< "$libraries"
