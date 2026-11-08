# Development

## Setup

Run `scripts/build.sh` once, or set up `build/helium-macos` the same way and
then run `source dev.sh && he setup` there. Afterwards `build/helium-macos/build/src`
is a patched Chromium tree, and `patches/helium/arc/arc-sidebar.patch` is the
top patch of its quilt series.

## Editing

The patch is managed with quilt and helium-macos's merged series:

```sh
cd build/helium-macos && source dev.sh
cd build/src
quilt add path/to/file.cc     # before editing a file the patch doesn't touch yet
# … edit …
quilt refresh
cp ../../patches/helium/arc/arc-sidebar.patch ../../../../patches/
```

Rebuild incrementally with `he build`, or with autoninja for one output
directory:

```sh
cd build/helium-macos/build/src
third_party/depot_tools/autoninja.py -C out/Default chrome
```

## Running a dev build

Use its own profile and the mock keychain so it doesn't touch your real
browser profile:

```sh
out/Default/Arcelium.app/Contents/MacOS/Arcelium \
  --user-data-dir="$HOME/Library/Application Support/io.github.andrew-sem.arcelium.dev" \
  --use-mock-keychain --no-first-run \
  --enable-features=HeliumNativeFrameMaterials
```

## Updating to a new Helium release

1. Set the new tag and commit in `scripts/helium-version.sh`.
2. Check out that tag in `build/helium-macos`, then run `git submodule update`.
3. Run `he reset && he setup`. If `arc-sidebar.patch` doesn't apply, fix the rejects and `quilt refresh`.
4. Copy the refreshed patch back into `patches/`.
