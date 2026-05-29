# homebrew-tap

Homebrew formulae for [bk1](https://github.com/keith-fajardo/bk1) — a deterministic dbt linter with a coding agent attached, for the terminal.

## Install

```sh
brew install keith-fajardo/tap/bk1
```

Prebuilt binaries are available for macOS (Apple Silicon) and Linux x64; more platforms are added as the upstream release workflow builds them.

After install, run `bk1` from inside a dbt project (a directory containing `dbt_project.yml`), or point it anywhere:

```sh
DBT_PROJECT_DIR=/path/to/dbt-project bk1
```

## Maintenance

`Formula/bk1.rb` is updated automatically by the `homebrew` job in the bk1 repo's release workflow on each `v*` tag. Manual edits will be overwritten on the next release.
