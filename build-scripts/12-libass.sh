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
# libass draws ASS and SRT subtitles for the subtitles and ass filters.
# It has no system font provider (no fontconfig, no CoreText), so that the
# same build works on every target.  Fonts come from the fontsdir option of
# the filters.

set -e
set -x

tag=$(repo-src/get-version.sh libass)
git clone --depth 1 https://github.com/libass/libass -b "$tag"
cd libass

meson setup build \
  --prefix=/usr/local \
  --libdir=lib \
  --buildtype=release \
  --default-library=static \
  --wrap-mode=nofallback \
  -Dfontconfig=disabled \
  -Dcoretext=disabled \
  -Ddirectwrite=disabled \
  -Drequire-system-font-provider=false \
  -Dlibunibreak=disabled \
  -Dtest=disabled \
  -Dcompare=disabled \
  -Dprofile=disabled \
  -Dfuzz=disabled \
  -Dcheckasm=disabled

meson compile -C build
# sudo can reset PATH (its secure_path option), so give it the full path of
# meson.
$SUDO "$(command -v meson)" install -C build
