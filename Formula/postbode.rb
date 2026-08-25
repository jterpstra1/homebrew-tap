class Postbode < Formula
  desc "Gmail to ClearFacts/QPS purchase-invoice agent (macOS launchd daemon)"
  homepage "https://github.com/vhco-pro/postbode"
  version "0.5.0"

  # Bumped automatically by .github/workflows/sync-postbode.yml, which reads
  # the latest vhco-pro/postbode release. Do not edit version/sha256 by hand.
  #
  # darwin-only on purpose: postbode shells out to osascript and launchctl,
  # reads the macOS Keychain via /usr/bin/security and installs as a launchd
  # LaunchAgent. There is no Linux build to point at.
  on_macos do
    on_arm do
      url "https://github.com/vhco-pro/postbode/releases/download/#{version}/postbode_#{version}_darwin_arm64.zip"
      sha256 "bedff51912c8f26562876bf06a7f1f81725eeafd81c390bd33bc6208d3036cc4"
    end
    on_intel do
      url "https://github.com/vhco-pro/postbode/releases/download/#{version}/postbode_#{version}_darwin_amd64.zip"
      sha256 "9905e90094921ef4bbf2be98d5c2e081692262f2472c3805cb00f9968be8b066"
    end
  end

  # Notifications go through terminal-notifier so clicking one opens the
  # review queue. The osascript fallback posts notifications *as Script
  # Editor* — macOS attributes the click to the posting app, so its "Show"
  # button opens Script Editor, which reads as broken. postbode degrades to
  # osascript when this is absent, so this is about the experience, not
  # about working at all.
  depends_on "terminal-notifier"

  def install
    bin.install "postbode"
  end

  service do
    run [opt_bin/"postbode", "daemon"]
    keep_alive true
    run_type :immediate
    log_path var/"log/postbode.log"
    error_log_path var/"log/postbode.log"
  end

  def caveats
    <<~EOS
      postbode needs two credentials before it can do anything:

        1. A ClearFacts personal access token with the scopes
           upload_document, read_administrations and statistics.
        2. A Google OAuth desktop client (User type: Internal if you are on
           Workspace — that avoids the 7-day refresh-token expiry), saved as
           credentials.json.

      The Gmail label it files submitted mail under must already exist and is
      matched by name; postbode will refuse to start the uploader rather than
      create a lookalike.

      Nothing is ever uploaded without you approving it in the review UI at
      http://127.0.0.1:7391 — run `postbode review` to open it.

      Start it with:  brew services start postbode
    EOS
  end

  test do
    assert_match "postbode", shell_output("#{bin}/postbode version")
  end
end
