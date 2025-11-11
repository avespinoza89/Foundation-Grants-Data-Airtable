#!/bin/bash
# Test using the records API instead of metadata API

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "================================================================================"
echo "TESTING AIRTABLE RECORDS API"
echo "================================================================================"
echo ""
echo "Configuration:"
echo "  API Key: ${AIRTABLE_API_KEY:0:20}..."
echo "  Base ID: $AIRTABLE_BASE_ID"
echo "  Table: $SOURCE_TABLE_NAME"
echo ""

# Try to read records from the source table
echo "Attempting to list tables in base..."
echo "--------------------------------------------------------------------------------"

# First, try to list all tables (requires schema.bases:read)
response=$(curl -s -w "\n%{http_code}" \
  "https://api.airtable.com/v0/meta/bases/${AIRTABLE_BASE_ID}/tables" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "HTTP Status: $http_code"
echo ""

if [ "$http_code" = "200" ]; then
    echo "✓ SUCCESS! Connected to base!"
    echo ""
    echo "Tables found:"
    echo "$body" | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f\"  - {t['name']}\") for t in data.get('tables', [])]" 2>/dev/null || echo "$body"
    echo ""

elif [ "$http_code" = "403" ]; then
    echo "✗ Still getting 403 Forbidden"
    echo ""
    echo "Let's check the error details:"
    echo "$body"
    echo ""
    echo "Trying alternative: Direct table access..."
    echo "--------------------------------------------------------------------------------"

    # Try accessing a specific table directly
    response2=$(curl -s -w "\n%{http_code}" \
      "https://api.airtable.com/v0/${AIRTABLE_BASE_ID}/${SOURCE_TABLE_NAME}?maxRecords=1" \
      -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

    http_code2=$(echo "$response2" | tail -n1)
    body2=$(echo "$response2" | sed '$d')

    echo "HTTP Status: $http_code2"

    if [ "$http_code2" = "200" ]; then
        echo "✓ SUCCESS! Can access table directly!"
        echo ""
        echo "Note: Schema API doesn't work but records API does."
        echo "This might be a scope limitation. The normalization scripts should still work!"
    else
        echo "✗ Also failed with status $http_code2"
        echo "$body2"
    fi
else
    echo "Unexpected status: $http_code"
    echo "$body"
fi

echo ""
echo "================================================================================"
