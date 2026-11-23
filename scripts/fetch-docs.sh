#!/bin/sh
# Pulls the docs from the seismic repo into src/content/docs/docs/, where Starlight reads them.
# The docs' source is docs/site/ in nickpalenchar/seismic; this directory is a gitignored copy.
#
#   SEISMIC_DOCS_REF    tag or branch to pull (default: docs-vlatest)
#   SEISMIC_DOCS_LOCAL  path to a local seismic checkout's docs/site/, copied instead of cloning,
#                       to preview edits that are not tagged yet
set -eu

repository="${SEISMIC_DOCS_REPOSITORY:-https://github.com/nickpalenchar/seismic.git}"
ref="${SEISMIC_DOCS_REF:-docs-vlatest}"
source_path="docs/site"

# Resolve a relative local path against the caller's directory before moving to the site root.
local_docs=""
if [ -n "${SEISMIC_DOCS_LOCAL:-}" ]; then
  local_docs="$(cd "$SEISMIC_DOCS_LOCAL" && pwd)"
fi

cd "$(dirname "$0")/.."
target="src/content/docs/docs"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

if [ -n "$local_docs" ] && [ "$local_docs" = "$(pwd)/$target" ]; then
  echo "fetch-docs: $target is already the source, nothing to copy"
  exit 0
elif [ -n "$local_docs" ]; then
  docs="$local_docs"
  origin="$local_docs"
else
  # Shallow, sparse and blob-less: only docs/site/ is downloaded, not the whole app.
  git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$ref" \
    --filter=blob:none --sparse "$repository" "$work/seismic"
  git -C "$work/seismic" sparse-checkout set "$source_path"
  docs="$work/seismic/$source_path"
  origin="$ref ($(git -C "$work/seismic" rev-parse --short HEAD))"
fi

if [ ! -d "$docs" ]; then
  echo "fetch-docs: $source_path not found at $origin" >&2
  exit 1
fi

# Swap only once the new copy is in hand, so a failed clone leaves the previous docs in place.
rm -rf "$target"
mkdir -p "$(dirname "$target")"
cp -R "$docs" "$target"
echo "fetch-docs: $target <- $origin"
