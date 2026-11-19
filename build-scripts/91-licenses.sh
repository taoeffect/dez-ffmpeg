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
# Writes LICENSES.txt: the license texts of ffmpeg and of each library that
# the programs hold, copied from the source code that the build scripts got.
# Run it after them, in the same folder.  The GPL and the LGPL ask that a copy
# of the programs comes with the license, and the BSD, MIT, ISC, and FreeType
# licenses that it carries their notice.  A missing file stops the build:
# then a library moved or renamed its license file.
#
# Each part starts with a rule line, the line "<name> <version>: <file>" (the
# name and the version of versions.txt), and another rule line.  Dez reads
# these lines (scripts/update-ffmpeg.js in the Dez repository), so keep their
# form.

set -e
set -x

out=LICENSES.txt
rule="================================================================================"

# Adds the license files of one library: its versions.txt name, its version,
# the folder of its source, and the files in that folder.
add_licenses() {
  name="$1"
  version="$2"
  folder="$3"
  shift 3
  for file in "$@"; do
    {
      echo "$rule"
      echo "$name $version: $file"
      echo "$rule"
      echo
      cat "$folder/$file"
      echo
    } >> "$out"
  done
}

cat > "$out" <<EOF
The license texts of the ffmpeg and ffprobe programs of dez-ffmpeg
(https://github.com/taoeffect/dez-ffmpeg), and of each library that they
hold, copied from the source code of the build.  musl is only in the Linux
programs.

EOF

add_licenses ffmpeg "$(repo-src/get-version.sh ffmpeg)" ffmpeg \
  LICENSE.md COPYING.GPLv3
add_licenses libvpx "$(repo-src/get-version.sh libvpx)" libvpx \
  LICENSE PATENTS
add_licenses svt-av1 "$(repo-src/get-version.sh svt-av1)" SVT-AV1 \
  LICENSE.md PATENTS.md
add_licenses x264 "$(repo-src/get-version.sh x264)" x264 \
  COPYING
add_licenses x265 "$(repo-src/get-version.sh x265)" x265_git \
  COPYING
lame_version=$(repo-src/get-version.sh lame)
add_licenses lame "$lame_version" lame-"$lame_version" \
  COPYING
add_licenses opus "$(repo-src/get-version.sh opus)" opus \
  COPYING
add_licenses zlib "$(repo-src/get-version.sh zlib)" zlib \
  LICENSE
# FreeType gives a choice of the FreeType License and the GPLv2.  Dez takes
# the FreeType License (docs/FTL.TXT).
add_licenses freetype "$(repo-src/get-version.sh freetype)" freetype \
  LICENSE.TXT docs/FTL.TXT
add_licenses harfbuzz "$(repo-src/get-version.sh harfbuzz)" harfbuzz \
  COPYING
add_licenses fribidi "$(repo-src/get-version.sh fribidi)" fribidi \
  COPYING
add_licenses libass "$(repo-src/get-version.sh libass)" libass \
  COPYING

# The static Linux programs hold the musl C library of the Alpine container
# (the libc.a of its musl-dev package).  Alpine ships no license file of
# musl, so get it from the musl source of that version.
if repo-src/is-alpine.sh; then
  musl_tag=v$(apk info -e -v musl-dev | sed -e 's/^musl-dev-//' -e 's/-r[0-9]*$//')
  git clone --depth 1 https://git.musl-libc.org/git/musl -b "$musl_tag" musl
  add_licenses musl "$musl_tag" musl \
    COPYRIGHT
fi

wc -c "$out"
