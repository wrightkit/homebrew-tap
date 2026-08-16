#!/usr/bin/env bash
# Keep wright.rb in this tap in sync with the latest wrightkit/wright release.
#
# The wright release pipeline attaches the authoritative formula
# (`wright-<version>.homebrew.rb`, generated from the published release
# checksums) to every GitHub Release. This script downloads that attachment
# and, when it differs from the committed formula, commits and pushes the
# update. Run by .github/workflows/sync-formula.yml (daily + on demand).
set -euo pipefail

OWNER="wrightkit"
REPO="wright"
FORMULA="wright.rb"

latest="$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest")"
tag="$(printf '%s' "$latest" | jq -r '.tag_name')"
version="${tag#v}"

formula_url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/wright-${version}.homebrew.rb"
if ! formula="$(curl -fsSL "$formula_url" 2>/dev/null)"; then
  # No manifest attached to this release (releases published before the
  # pipeline attached manifests, e.g. v0.1.0). If the committed formula
  # already covers the latest version we are current; otherwise surface the
  # gap instead of silently staying stale.
  if [[ -f "$FORMULA" ]] && grep -q "releases/download/v${version}/" "$FORMULA"; then
    echo "no manifest attached to ${tag}, but wright.rb already covers ${version}; nothing to do"
    exit 0
  fi
  echo "error: release ${tag} has no ${version}.homebrew.rb manifest and wright.rb is out of date" >&2
  exit 1
fi

# Sanity checks: must be the Wright formula for the expected version.
printf '%s' "$formula" | grep -q '^class Wright < Formula$' || {
  echo "error: downloaded manifest is not a Wright formula; aborting" >&2
  exit 1
}
printf '%s' "$formula" | grep -q "releases/download/v${version}/" || {
  echo "error: downloaded formula does not reference release ${tag}; aborting" >&2
  exit 1
}

if [[ -f "$FORMULA" ]] && [[ "$(cat "$FORMULA")" == "$formula" ]]; then
  echo "wright.rb is already current for ${tag}; nothing to do"
  exit 0
fi

printf '%s\n' "$formula" > "$FORMULA"
git add "$FORMULA"
git -c user.name="wrightkit-bot" \
    -c user.email="wrightkit-bot@users.noreply.github.com" \
    commit -m "Update wright formula to ${version}

Generated from the wright ${tag} release manifest."
git push origin HEAD

echo "updated wright.rb to ${version}"
