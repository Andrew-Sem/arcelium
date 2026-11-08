#!/usr/bin/env bash
# Builds Arcelium: Helium for macOS with the patches of this repo.
#
#   scripts/build.sh [arm64|x86_64]
#
# Clones helium-macos at the pinned version into build/helium-macos, adds the
# patches to its series, swaps Helium's name and icon for Arcelium's and runs
# its release build, which downloads Chromium and takes hours. The app and a
# .dmg end up in build/helium-macos/build/.
# Needs what helium-macos needs: Xcode, Homebrew's coreutils, quilt and
# python 3, see https://github.com/imputnet/helium-macos.

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
source "$root/scripts/helium-version.sh"

work="$root/build/helium-macos"
if [ ! -d "$work" ]; then
  git clone --recurse-submodules --branch "$HELIUM_MACOS_TAG" \
    https://github.com/imputnet/helium-macos.git "$work"
fi
cd "$work"
if [ "$(git rev-parse HEAD)" != "$HELIUM_MACOS_COMMIT" ]; then
  echo "build/helium-macos is not at $HELIUM_MACOS_TAG; remove it to start over" >&2
  exit 1
fi

mkdir -p patches/helium/arc
cp "$root"/patches/*.patch patches/helium/arc/
for patch in "$root"/patches/*.patch; do
  entry="helium/arc/$(basename "$patch")"
  grep -qxF "$entry" patches/series || echo "$entry" >> patches/series
done

# The name and icon. The patches rename the app itself; these are the
# strings that say Chromium, which Helium's build names after itself, and
# its packaging.
cp "$root/branding/Assets.car" "$root/branding/app.icns" resources/assets/
sed -i '' "s/r'Helium'),/r'Arcelium'),/" \
  helium-chromium/utils/name_substitution_utils.py
sed -i '' -e 's/Helium\.app/Arcelium.app/g' \
  -e 's/Helium Packaging/Arcelium Packaging/' \
  -e 's/Helium\.provisionprofile/Arcelium.provisionprofile/' \
  -e 's/--volname Helium/--volname Arcelium/' \
  -e 's|build/helium_|build/arcelium_|' \
  -e 's/--identifier net\.imput\.helium/--identifier io.github.andrew-sem.arcelium/' \
  sign_and_package_app.sh

exec ./build.sh "$@"
