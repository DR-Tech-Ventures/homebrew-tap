# DR Tech Ventures Homebrew tap

Homebrew casks for DR Tech Ventures software.

## Install

```bash
brew install --cask dr-tech-ventures/tap/icloud-gui
```

`brew` adds the tap on first use, so there is no need to `brew tap` first.

Use the **full** `dr-tech-ventures/tap/icloud-gui` name, not the short `icloud-gui`.
Since Homebrew 6.0 a tap outside the official ones has to be trusted before its code is
loaded, and installing by full name is what grants that trust. Short-name commands fail
until the tap is trusted explicitly:

```bash
brew trust dr-tech-ventures/tap                      # whole tap
brew trust --cask dr-tech-ventures/tap/icloud-gui    # or just this cask
```

Trusting nothing and always typing the full name works fine too.

## What is here

| Cask | Description | Requires |
| --- | --- | --- |
| `icloud-gui` | [iCloud GUI](https://github.com/DR-Tech-Ventures/icloud-gui) — downloads iCloud Photos originals to a local folder or NAS | macOS 27 |

## Why a tap rather than homebrew/cask

Homebrew's [package acceptance policy](https://docs.brew.sh/Package-Acceptance-Policy)
asks a new cask to be notable: 30 forks, 30 watchers or 75 stars, tripled to 90 / 90 /
225 when the person submitting it owns the repository. That is a reasonable bar for a
volunteer-run index and this software does not clear it, so it lives here instead.

Nothing is lost by it. A tap is a normal Homebrew install: the same `brew install
--cask`, the same upgrade path, the same uninstall. The only difference is the tap name
in front.

## Upgrading

```bash
brew upgrade --cask dr-tech-ventures/tap/icloud-gui
```

The short `brew upgrade --cask icloud-gui` works only once the tap is trusted — see the
note under Install.

If you installed iCloud GUI by dragging it out of the disk image, Homebrew will refuse
to take over the existing copy. Move it to the Trash first, then install — your
downloaded photos are untouched by this, since they live in whichever destination folder
you picked, not inside the app.

## Uninstalling

```bash
brew uninstall --cask icloud-gui
```

To remove preferences as well:

```bash
brew zap --cask icloud-gui
```

`zap` removes the app's preferences and saved window state. **It does not touch your
downloaded photos**, nor the `.icloudgui-index.tsv` and `.icloudgui-log.txt` files the
app writes beside them — those live in the destination folder you chose, and nothing
here will go looking for it.

## Verifying a download yourself

Releases are signed with a Developer ID certificate and notarised by Apple. Homebrew
checks the SHA-256 in the cask, and macOS checks the signature. To see it for yourself:

```bash
spctl -a -vvv "/Applications/iCloud GUI.app"
```

Expected:

```
accepted
source=Notarized Developer ID
origin=Developer ID Application: DR Tech Ventures LLC (DJ2RANBKU3)
```

## Maintaining this tap

Each iCloud GUI release needs two lines changed in `Casks/icloud-gui.rb` — `version` and
`sha256` — or Homebrew reports a checksum mismatch and the install fails. The checksum of
a published release is:

```bash
curl -fsSL https://github.com/DR-Tech-Ventures/icloud-gui/releases/download/vX.Y/iCloud-GUI.dmg | shasum -a 256
```

Then check the result before pushing. `brew audit` and `brew fetch` take a cask *name*,
not a path, and both refuse an untrusted tap — so trust it once on the machine you
maintain from:

```bash
brew trust dr-tech-ventures/tap
brew audit --cask --online --new dr-tech-ventures/tap/icloud-gui
brew fetch --cask --force dr-tech-ventures/tap/icloud-gui
```

`brew install --cask --dry-run dr-tech-ventures/tap/icloud-gui` needs no trust and
catches deprecated stanzas, which is worth running even without the rest.

A release that raises the minimum macOS version also needs `depends_on macos:` updated.
Homebrew's symbol for a given version comes from Homebrew itself, not from Apple's
marketing name:

```bash
brew ruby -e 'require "macos_version"; puts MacOSVersion::SYMBOLS'
```

## Licence

The cask definitions here are Apache-2.0, matching the software they install.
