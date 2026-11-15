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
# HarfBuzz shapes the text of the drawtext filter and of libass.
# The drawtext filter uses its FreeType functions (hb-ft), so FreeType is on.
# Every other library and every extra HarfBuzz library is off.

set -e
set -x

tag=$(repo-src/get-version.sh harfbuzz)
git clone --depth 1 https://github.com/harfbuzz/harfbuzz -b "$tag"
cd harfbuzz

meson setup build \
  --prefix=/usr/local \
  --libdir=lib \
  --buildtype=release \
  --default-library=static \
  --wrap-mode=nofallback \
  -Dfreetype=enabled \
  -Dglib=disabled \
  -Dgobject=disabled \
  -Dcairo=disabled \
  -Dchafa=disabled \
  -Dicu=disabled \
  -Dpng=disabled \
  -Dzlib=disabled \
  -Draster=disabled \
  -Dvector=disabled \
  -Dgpu=disabled \
  -Dgpu_demo=disabled \
  -Dsubset=disabled \
  -Dtests=disabled \
  -Dintrospection=disabled \
  -Ddocs=disabled \
  -Dutilities=disabled \
  -Dbenchmark=disabled

meson compile -C build
# sudo can reset PATH (its secure_path option), so give it the full path of
# meson.
$SUDO "$(command -v meson)" install -C build
