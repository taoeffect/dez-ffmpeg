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
# Checks that ffmpeg runs the filters of the Rubber Band Library and of
# vid.stab.  A link check does not see a library that fails at run time (a
# missing C++ runtime part, a CPU path of one target), so run each filter.

set -e
set -x

cd ffmpeg

./ffmpeg -v error -f lavfi -i sine=frequency=440:duration=1 \
  -af rubberband=tempo=1.5:pitch=1.2 -f null -
./ffmpeg -v error -f lavfi -i testsrc2=size=160x90:rate=10:duration=1 \
  -vf vidstabdetect=result=check.trf -f null -
./ffmpeg -v error -f lavfi -i testsrc2=size=160x90:rate=10:duration=1 \
  -vf vidstabtransform=input=check.trf -f null -
rm check.trf
