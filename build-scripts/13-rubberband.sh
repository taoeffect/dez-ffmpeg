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

# Added for Dez, in the style of the Shaka Project's build scripts.
# The Rubber Band Library changes the tempo and the pitch of audio for the
# rubberband filter.
# It uses its own FFT and resampler on every target: no other library, and
# on macOS not the Accelerate framework, which the default "auto" takes
# there.  So every target runs the same code.  The plugins, the Java
# interface, the program, and the tests are off.

set -e
set -x

tag=$(repo-src/get-version.sh rubberband)
git clone --depth 1 https://github.com/breakfastquay/rubberband -b "$tag"
cd rubberband

# src/common/mathmisc.h uses size_t but includes no header that defines it.
# New versions of libc++ (Apple clang 21 on the macOS runner) no longer give
# it through <math.h>, so the build fails there with "unknown type name
# 'size_t'".  meson takes CXXFLAGS as the C++ arguments of the build.
CXXFLAGS="${CXXFLAGS:-} -include cstddef" meson setup build \
  --prefix=/usr/local \
  --libdir=lib \
  --buildtype=release \
  --default-library=static \
  --wrap-mode=nofallback \
  -Dfft=builtin \
  -Dresampler=builtin \
  -Djni=disabled \
  -Dladspa=disabled \
  -Dlv2=disabled \
  -Dvamp=disabled \
  -Dcmdline=disabled \
  -Dtests=disabled

meson compile -C build
# sudo can reset PATH (its secure_path option), so give it the full path of
# meson.
$SUDO "$(command -v meson)" install -C build
