cask "icloud-gui" do
  version "1.4"
  sha256 "206df559c3d9f8715a8326c759f5b70c4144dee4ae5a08016b80d7ce64641b25"

  url "https://github.com/DR-Tech-Ventures/icloud-gui/releases/download/v#{version}/iCloud-GUI.dmg"
  name "iCloud GUI"
  desc "Downloads iCloud Photos originals to a local folder or NAS"
  homepage "https://github.com/DR-Tech-Ventures/icloud-gui"

  livecheck do
    url :url
    strategy :github_latest
  end

  # 1.4 raised the minimum from macOS 26. `:golden_gate` is Homebrew's own symbol for
  # macOS 27, read out of MacOSVersion::SYMBOLS rather than taken from the marketing
  # name -- the two have disagreed before.
  #
  # A bare symbol is a MINIMUM, not an exact match: `depends_on macos=` parses its
  # argument with `comparator: ">="`. So this stays correct on macOS 28 without being
  # touched. The older `">= :golden_gate"` spelling means the same thing but is
  # deprecated, and warns on every install.
  depends_on macos: :golden_gate

  app "iCloud GUI.app"

  # Preferences and window state, and nothing else.
  #
  # DELIBERATELY ABSENT: the index (.icloudgui-index.tsv) and run log
  # (.icloudgui-log.txt) that the app writes into whichever destination folder the user
  # picked. That folder holds their downloaded photos -- it IS the backup, it lives
  # wherever they chose, and `brew zap` has no business going near it. Losing the index
  # on its own is survivable, since the app falls back to matching filenames, but it is
  # still the user's data in the user's folder.
  zap trash: [
    "~/Library/Preferences/com.drtechventures.icloudgui.plist",
    "~/Library/Saved Application State/com.drtechventures.icloudgui.savedState",
  ]
end
