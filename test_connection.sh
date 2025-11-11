#!/bin/bash
# ============================================================================
# QUICK AIRTABLE CONNECTION TEST (Bash/curl)
# ============================================================================
# Run this to quickly test your Airtable connection without R

echo ""
echo "================================================================================"
echo "TESTING AIRTABLE API CONNECTION"
echo "================================================================================"
echo ""

# Load credentials from .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ Loaded .env file"
else
    echo "✗ ERROR: .env file not found"
    exit 1
fi

echo "✓ API Key: ${AIRTABLE_API_KEY:0:15}..."
echo "✓ Base ID: $AIRTABLE_BASE_ID"
echo ""

# Test API connection
echo "Testing API connection..."
echo "--------------------------------------------------------------------------------"

response=$(curl -s -w "\n%{http_code}" \
  "https://api.airtable.com/v0/meta/bases/${AIRTABLE_BASE_ID}/tables" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo "✓ SUCCESS: Connected to Airtable!"
    echo ""
    echo "Tables in your base:"
    echo "$body" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | nl
    echo ""
elif [ "$http_code" = "401" ]; then
    echo "✗ FAILED: Unauthorized (401)"
    echo "Your API token is invalid or missing required scopes."
    echo ""
    echo "Required scopes:"
    echo "  - data.records:read"
    echo "  - data.records:write"
    echo "  - schema.bases:read"
    echo ""
elif [ "$http_code" = "403" ]; then
    echo "✗ FAILED: Forbidden (403)"
    echo "Your token doesn't have access to this base."
    echo "Make sure you added this base when creating the token."
    echo ""
elif [ "$http_code" = "404" ]; then
    echo "✗ FAILED: Not Found (404)"
    echo "Base ID may be incorrect: $AIRTABLE_BASE_ID"
    echo ""
else
    echo "✗ FAILED: HTTP $http_code"
    echo "$body"
    echo ""
fi

echo "================================================================================"
