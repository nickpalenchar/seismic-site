# Pull the docs from seismic's docs-vlatest tag. To preview a local checkout's untagged edits:
#   SEISMIC_DOCS_LOCAL=../obeya/docs/site just docs
docs:
    sh scripts/fetch-docs.sh

# Start the dev server, reachable from other machines (e.g. http://nicks-mac-studio:4321).
# Pulls the docs first if there is no copy yet; `just docs` refreshes it.
dev:
    [ -d src/content/docs/docs ] || just docs
    npm run dev -- --host

# One-time: the AWS role GitHub Actions deploys with, and the repo variables it reads.
deploy-role:
    sh scripts/deploy-role.sh
