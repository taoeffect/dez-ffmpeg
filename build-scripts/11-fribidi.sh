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
# FriBidi puts right-to-left text in order for the drawtext filter and libass.

set -e
set -x

tag=$(repo-src/get-version.sh fribidi)
git clone --depth 1 https://github.com/fribidi/fribidi -b "$tag"
cd fribidi

meson setup build \
  --prefix=/usr/local \
  --libdir=lib \
  --buildtype=release \
  --default-library=static \
  --wrap-mode=nofallback \
  -Ddocs=false \
  -Dbin=false \
  -Dtests=false

meson compile -C build
# sudo can reset PATH (its secure_path option), so give it the full path of
# meson.
$SUDO "$(command -v meson)" install -C build
