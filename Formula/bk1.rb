# Template for the bk1 Homebrew formula.
#
# This is the SOURCE OF TRUTH. The `homebrew` job in
# .github/workflows/release.yml substitutes the @@...@@ placeholders with each
# `v*` release's version + per-platform sha256 and pushes the result to the tap
# repo (github.com/keith-fajardo/homebrew-tap) as Formula/bk1.rb — which is
# what `brew install keith-fajardo/tap/bk1` reads.
#
# Placeholders: 0.4.11  2aa7a6277dc03340bdbf25cf145839adfbd5a9b485022702f1f76345d829b313  b26253d70489b961c2c9a08d9347202169cd60b5799e985e3a0493e8ceb00eca  76f63b9aeff3cd5ca192c10e1b86480cc4d6665368b782e06099abdd30fffdfa
class Bk1 < Formula
  desc "Deterministic dbt linter with a coding agent attached, for the terminal"
  homepage "https://github.com/keith-fajardo/bk1"
  version "0.4.11"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.11/bk1-0.4.11-darwin-arm64.tar.gz"
      sha256 "2aa7a6277dc03340bdbf25cf145839adfbd5a9b485022702f1f76345d829b313"
    end
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.11/bk1-0.4.11-darwin-x64.tar.gz"
      sha256 "b26253d70489b961c2c9a08d9347202169cd60b5799e985e3a0493e8ceb00eca"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.11/bk1-0.4.11-linux-x64.tar.gz"
      sha256 "76f63b9aeff3cd5ca192c10e1b86480cc4d6665368b782e06099abdd30fffdfa"
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
