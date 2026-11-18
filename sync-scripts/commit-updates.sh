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
# The step "Update ffmpeg and the libraries that Dez adds" of the Sync
# upstream workflow.  Runs update-versions.sh (with MIN_AGE_DAYS), and
# commits its changes.  Its lines go to $RUNNER_TEMP/libraries.txt, as a
# list, and into the commit message.

set -e -o pipefail
set -x

cd "$(dirname "$0")/.."

sync-scripts/update-versions.sh | sed -e 's/^/- /' > "$RUNNER_TEMP/libraries.txt"
if [[ -s "$RUNNER_TEMP/libraries.txt" ]]; then
  git commit -a \
      -m "Update ffmpeg and the libraries that Dez adds" \
      -m "$(cat "$RUNNER_TEMP/libraries.txt")"
fi
