# Template for the bk1 Homebrew formula.
#
# This is the SOURCE OF TRUTH. The `homebrew` job in
# .github/workflows/release.yml substitutes the @@...@@ placeholders with each
# `v*` release's version + per-platform sha256 and pushes the result to the tap
# repo (github.com/keith-fajardo/homebrew-tap) as Formula/bk1.rb — which is
# what `brew install keith-fajardo/tap/bk1` reads.
#
# Placeholders: 0.4.20  669f22fb805ce6fa2bae7010a5817fe99701e9200927ba403545ea1a79e7e046  f74b1fe653f40ad807c06980ae18a0f09d9c23227035a42dda33a9c7002eade6  88f9850342d79b522b9a5ede472cc3130963a2a1febbc8dab2ceaa0c4bb83c2c
class Bk1 < Formula
  desc "Deterministic dbt linter with a coding agent attached, for the terminal"
  homepage "https://github.com/keith-fajardo/bk1"
  version "0.4.20"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.20/bk1-0.4.20-darwin-arm64.tar.gz"
      sha256 "669f22fb805ce6fa2bae7010a5817fe99701e9200927ba403545ea1a79e7e046"
    end
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.20/bk1-0.4.20-darwin-x64.tar.gz"
      sha256 "f74b1fe653f40ad807c06980ae18a0f09d9c23227035a42dda33a9c7002eade6"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.20/bk1-0.4.20-linux-x64.tar.gz"
      sha256 "88f9850342d79b522b9a5ede472cc3130963a2a1febbc8dab2ceaa0c4bb83c2c"
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
