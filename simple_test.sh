#!/bin/bash
# Simple direct test of base access

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "Testing direct base access..."
echo "Base ID: $AIRTABLE_BASE_ID"
echo ""

# Try to list tables directly
curl -v "https://api.airtable.com/v0/meta/bases/${AIRTABLE_BASE_ID}/tables" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}" 2>&1
