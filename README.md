# WrightKit Homebrew Tap

Homebrew tap for [Wright](https://github.com/wrightkit/wright), the
developer CLI for Overwatch Workshop projects. Provides `wright` and `wright-lsp` as standalone macOS binaries
(Apple Silicon and Intel); nothing here builds Wright from source.

```sh
brew tap wrightkit/tap
brew install wrightkit/tap/wright
```

Upgrade after a new release with:

```sh
brew upgrade wrightkit/tap/wright
```

## How the formula is kept up to date

`wright.rb` is not edited by hand. The
[wright release pipeline](https://github.com/wrightkit/wright/actions/workflows/release.yml)
generates the formula from the published release checksums and its
`publish-tap` job pushes it here automatically on every stable release, as
soon as the release is published. Prereleases and nightly builds do not reach
this tap.
