#!/bin/zsh
# This script extracts coverage percent and uploads it to a GitHub Gist for shields.io dynamic badge
# Requirements: gh CLI authenticated, GIST_ID and GIST_TOKEN set as secrets in your GitHub Actions

# 1. Extract coverage percent from lcov.info
COVERAGE_FILE="coverage/lcov.info"
if [ ! -f "$COVERAGE_FILE" ]; then
  echo "Coverage file not found: $COVERAGE_FILE"
  exit 1
fi

total_lines=$(awk -F: '/^LF:/ {s+=$2} END {print s}' "$COVERAGE_FILE")
covered_lines=$(awk -F: '/^LH:/ {s+=$2} END {print s}' "$COVERAGE_FILE")
if [ -z "$total_lines" ] || [ "$total_lines" -eq 0 ]; then
  COVERAGE_PERCENT=0
else
  COVERAGE_PERCENT=$(awk "BEGIN { printf \"%.1f\", ($covered_lines/$total_lines)*100 }")
fi

# 2. Create JSON for shields.io
cat > coverage.json <<EOF
{
  "schemaVersion": 1,
  "label": "coverage",
  "message": "${COVERAGE_PERCENT}%",
  "color": "brightgreen"
}
EOF

# 3. Create payload for Gist API
cat > payload.json <<EOF
{
  "files": {
    "coverage.json": {
      "content": $(jq -Rs . < coverage.json)
    }
  }
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
  -H "Content-Type: application/json" \
  --data-binary @payload.json \
  https://api.github.com/gists/$GIST_ID
