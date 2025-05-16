#!/bin/zsh
# This script extracts coverage percent and uploads it to a GitHub Gist for shields.io dynamic badge
# Requirements: gh CLI authenticated, GIST_ID and GIST_TOKEN set as secrets in your GitHub Actions

# 1. Extract coverage percent from lcov.info
COVERAGE_FILE="coverage/lcov.info"
if [ ! -f "$COVERAGE_FILE" ]; then
  echo "Coverage file not found: $COVERAGE_FILE"
  exit 1
fi

COVERAGE_PERCENT=$(genhtml $COVERAGE_FILE --stdout | grep -o 'lines......: [0-9.]*%' | awk '{print $2}' | tr -d '%')

# 2. Create JSON for shields.io
cat <<EOF > coverage.json
{
  "schemaVersion": 1,
  "label": "coverage",
  "message": "${COVERAGE_PERCENT}%",
  "color": "brightgreen"
}
EOF

# 3. Upload to Gist (requires GIST_ID and GIST_TOKEN)
GIST_ID=${GIST_ID:-"YOUR_GIST_ID"}
GIST_TOKEN=${GIST_TOKEN:-"YOUR_GIST_TOKEN"}

if [ "$GIST_ID" = "YOUR_GIST_ID" ] || [ "$GIST_TOKEN" = "YOUR_GIST_TOKEN" ]; then
  echo "Please set GIST_ID and GIST_TOKEN as environment variables or in your GitHub Actions secrets."
  exit 1
fi

curl -X PATCH \
  -H "Authorization: token $GIST_TOKEN" \
  -d '{"files": {"coverage.json": {"content": "'$(cat coverage.json | sed 's/"/\\"/g')'"}}}' \
  https://api.github.com/gists/$GIST_ID
