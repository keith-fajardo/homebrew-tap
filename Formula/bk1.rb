# Template for the bk1 Homebrew formula.
#
# This is the SOURCE OF TRUTH. The `homebrew` job in
# .github/workflows/release.yml substitutes the @@...@@ placeholders with each
# `v*` release's version + per-platform sha256 and pushes the result to the tap
# repo (github.com/keith-fajardo/homebrew-tap) as Formula/bk1.rb — which is
# what `brew install keith-fajardo/tap/bk1` reads.
#
# Placeholders: 0.4.17  db0359c643ee9de10ac13c4d3b712897e885950adb0804196a3bf56ff26d619e  00f3fa09a4c8ca86f2bd95465a213613eb7ede789f533a9109653d7575522f20  8c555e0e6ee53747558685c163d9a56f1001e407469e47a79fb504c314059e5d
class Bk1 < Formula
  desc "Deterministic dbt linter with a coding agent attached, for the terminal"
  homepage "https://github.com/keith-fajardo/bk1"
  version "0.4.17"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.17/bk1-0.4.17-darwin-arm64.tar.gz"
      sha256 "db0359c643ee9de10ac13c4d3b712897e885950adb0804196a3bf56ff26d619e"
    end
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.17/bk1-0.4.17-darwin-x64.tar.gz"
      sha256 "00f3fa09a4c8ca86f2bd95465a213613eb7ede789f533a9109653d7575522f20"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.17/bk1-0.4.17-linux-x64.tar.gz"
      sha256 "8c555e0e6ee53747558685c163d9a56f1001e407469e47a79fb504c314059e5d"
    end
    on_arm do
      odie "bk1 does not ship a prebuilt Linux arm64 binary yet. Build from source: #{homepage}"
    end
  end

  def install
    # Keep bk1, bk1-lint, and kimball/ together in libexec; bk1 resolves its
    # sidecars sibling-of-binary at runtime (see src/bk1-home.ts). Symlinking
    # only bk1 into bin keeps bk1-lint off the user's PATH.
    libexec.install "bk1", "bk1-lint", "kimball"
    bin.install_symlink libexec/"bk1"
  end

  def caveats
    <<~EOS
      bk1 needs an Anthropic API key (prompted on first run, stored at
      ~/.bk1/auth.json) and a dbt project on disk. Launch it from inside a
      project that contains dbt_project.yml, or point it anywhere with:

        DBT_PROJECT_DIR=/path/to/dbt-project bk1
    EOS
  end

  test do
    # bk1 itself launches a full-screen TUI, so exercise the lint sidecar,
    # which has a non-interactive --help and proves the tarball laid out right.
    assert_predicate libexec/"bk1-lint", :exist?
    assert_predicate libexec/"kimball/kimball.db", :exist?
    system libexec/"bk1-lint", "--help"
  end
end
