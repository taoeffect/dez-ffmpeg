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
# FreeType draws the glyphs of the drawtext filter and of libass.
# It is built with no optional library: harfbuzz uses FreeType, so FreeType
# must not use harfbuzz, and fonts come as plain files.

set -e
set -x

tag=$(repo-src/get-version.sh freetype)
git clone --depth 1 https://gitlab.freedesktop.org/freetype/freetype.git -b "$tag"
cd freetype

meson setup build \
  --prefix=/usr/local \
  --libdir=lib \
  --buildtype=release \
  --default-library=static \
  --wrap-mode=nofallback \
  -Dbrotli=disabled \
  -Dbzip2=disabled \
  -Dharfbuzz=disabled \
  -Dpng=disabled \
  -Dzlib=disabled \
  -Dtests=disabled

meson compile -C build
# sudo can reset PATH (its secure_path option), so give it the full path of
# meson.
$SUDO "$(command -v meson)" install -C build
