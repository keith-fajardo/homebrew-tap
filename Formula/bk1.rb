# Template for the bk1 Homebrew formula.
#
# This is the SOURCE OF TRUTH. The `homebrew` job in
# .github/workflows/release.yml substitutes the @@...@@ placeholders with each
# `v*` release's version + per-platform sha256 and pushes the result to the tap
# repo (github.com/keith-fajardo/homebrew-tap) as Formula/bk1.rb — which is
# what `brew install keith-fajardo/tap/bk1` reads.
#
# Placeholders: 0.4.12  fdea99f507ebdf0eb939d1d902cab805bda30bc9f44a26bc886aa50526542e9f  e38213b70f9ee05bb56ae2fc5af4f7883b7b3c60bcc41220395e812de01a3465  9a2c6b25c0c4c3ec4d5a9cd7f9d50b878205d491130ac6833496e460f10a0793
class Bk1 < Formula
  desc "Deterministic dbt linter with a coding agent attached, for the terminal"
  homepage "https://github.com/keith-fajardo/bk1"
  version "0.4.12"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.12/bk1-0.4.12-darwin-arm64.tar.gz"
      sha256 "fdea99f507ebdf0eb939d1d902cab805bda30bc9f44a26bc886aa50526542e9f"
    end
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.12/bk1-0.4.12-darwin-x64.tar.gz"
      sha256 "e38213b70f9ee05bb56ae2fc5af4f7883b7b3c60bcc41220395e812de01a3465"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/keith-fajardo/bk1/releases/download/v0.4.12/bk1-0.4.12-linux-x64.tar.gz"
      sha256 "9a2c6b25c0c4c3ec4d5a9cd7f9d50b878205d491130ac6833496e460f10a0793"
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
