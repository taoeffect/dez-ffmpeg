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
# Checks that ffmpeg reads an MPEG-TS file.  The static musl builds of FFmpeg
# n9.0.2 crashed on every MPEG-TS input (see ffmpeg-mpegts-stack.patch), and
# no other step saw it: a large stack frame of a demuxer thread fails only at
# run time.

set -e
set -x

cd ffmpeg

./ffmpeg -v error -y -f lavfi -i sine=frequency=440:duration=0.2 -c:a mp2 check.ts
./ffmpeg -v error -i check.ts -f null -
rm check.ts
