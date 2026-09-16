# Building RemoteAccess for macOS locally

macOS builds run on Marcello's Mac, not GitHub Actions (macOS runners bill at 10x).

Prereqs: Xcode, Rust (`rustup`), Flutter 3.24.5 (`fvm` or `flutter version 3.24.5`),
`brew install create-dmg`, `cargo install flutter_rust_bridge_codegen --version 1.80.1 --features uuid --locked`.

```sh
cd ~/Development/modul4r/rustdesk-remote
git checkout modul4r && git pull
python3 build.py --flutter            # builds librustdesk + flutter app, then makes rustdesk.dmg
```

`build.py --flutter` on macOS finishes with an unsigned `rustdesk.dmg` at the repo
root (it runs `flutter build macos --release`, copies the `service` binary into the
app bundle, and calls `create-dmg`). Rename and ship:

```sh
mv rustdesk.dmg RemoteAccess-<version>-macos-arm64.dmg
gh release upload 1.5.0-remote1 RemoteAccess-<version>-macos-arm64.dmg --clobber
```

Unsigned: first launch needs right-click → Open (Gatekeeper). Code sign with your
Apple ID team by exporting `MACOS_CODESIGN_IDENTITY` and following
`res/osx-dist.sh` (codesign + create-dmg + notarize via `rcodesign`) if you want no
Gatekeeper prompt.
