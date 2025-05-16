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
echo '{' > coverage.json
echo '  "schemaVersion": 1,' >> coverage.json
echo '  "label": "coverage",' >> coverage.json
echo '  "message": "'${COVERAGE_PERCENT}'%",' >> coverage.json
echo '  "color": "brightgreen"' >> coverage.json
echo '}' >> coverage.json

# 3. Upload to Gist (requires GIST_ID and GIST_TOKEN)
GIST_ID=${GIST_ID:-"YOUR_GIST_ID"}
GIST_TOKEN=${GIST_TOKEN:-"YOUR_GIST_TOKEN"}

if [ "$GIST_ID" = "YOUR_GIST_ID" ] || [ "$GIST_TOKEN" = "YOUR_GIST_TOKEN" ]; then
  echo "Please set GIST_ID and GIST_TOKEN as environment variables or in your GitHub Actions secrets."
  exit 1
fi

COVERAGE_JSON_ESCAPED=$(cat coverage.json | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')

curl -X PATCH \
  -H "Authorization: token $GIST_TOKEN" \
  -d '{"files": {"coverage.json": {"content": "'$COVERAGE_JSON_ESCAPED'"}}}' \
  https://api.github.com/gists/$GIST_ID
