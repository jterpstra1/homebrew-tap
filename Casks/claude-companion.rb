cask "claude-companion" do
  version "0.8.0"
  sha256 "abbaadd49ec2e6cd63c4a7f13b50f55c0a3a6b196a824c5ee9209bd19f200be8"

  url "https://github.com/vhco-pro/claude-companion/releases/download/v#{version}/ClaudeCompanion-#{version}.zip"
  name "Claude Companion"
  desc "Menu-bar companion for Claude Code that auto-approves unblacklisted tool calls"
  homepage "https://github.com/vhco-pro/claude-companion"

  depends_on macos: :sonoma

  app "ClaudeCompanion.app"

  # The app is ad-hoc signed (not notarized), so a quarantined copy is hard-blocked by Gatekeeper
  # ("cannot be verified - move to Trash"), and the companion-hook copied out of the bundle inherits
  # the quarantine bit and gets killed when Claude Code runs it. Strip quarantine right after install
  # so the app launches and the gate runs without any manual `xattr` step.
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/ClaudeCompanion.app"]
  end

  zap trash: [
    "~/.config/claude-companion",
    "~/Library/Preferences/pro.vhco.claude-companion.plist",
  ]

  caveats <<~EOS
    Claude Companion is ad-hoc signed (not notarized). This cask strips the download
    quarantine automatically on install. If macOS still blocks it, run:

      xattr -dr com.apple.quarantine "#{appdir}/ClaudeCompanion.app"

    The headline auto-approve gate installs a Claude Code hook from inside the app
    (a button in the popover), then reload your editor window to activate it.
  EOS
end
