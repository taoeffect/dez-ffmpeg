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
# vid.stab stabilizes video for the vidstabdetect and vidstabtransform
# filters.
# OpenMP is off: on Linux it would add the libgomp runtime, and the clang of
# macOS has none.  The library goes in lib/ on every system (GNUInstallDirs
# can take lib64/ or lib/<triplet>/, which pkg-config does not search).

set -e
set -x

tag=$(repo-src/get-version.sh vidstab)
git clone --depth 1 https://github.com/georgmartius/vid.stab -b "$tag"

mkdir vid.stab-build
cd vid.stab-build

cmake ../vid.stab \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DUSE_OMP=OFF

make
$SUDO make install
