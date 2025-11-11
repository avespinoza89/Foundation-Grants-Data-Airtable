#!/bin/bash
# ============================================================================
# DETAILED AIRTABLE TOKEN DIAGNOSTIC
# ============================================================================

echo ""
echo "================================================================================"
echo "AIRTABLE TOKEN DIAGNOSTIC"
echo "================================================================================"
echo ""

# Load credentials
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "✗ ERROR: .env file not found"
    exit 1
fi

echo "Configuration:"
echo "  API Key: ${AIRTABLE_API_KEY:0:20}..."
echo "  Base ID: $AIRTABLE_BASE_ID"
echo ""

# Test 1: Check if token is valid at all
echo "Test 1: Checking token validity..."
echo "--------------------------------------------------------------------------------"

response=$(curl -s -w "\n%{http_code}" \
  "https://api.airtable.com/v0/meta/whoami" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo "✓ Token is VALID"
    echo ""
    echo "Token details:"
    echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    echo ""
else
    echo "✗ Token is INVALID (HTTP $http_code)"
    echo "$body"
    echo ""
    exit 1
fi

# Test 2: Try to list bases (requires different scope)
echo "Test 2: Attempting to list accessible bases..."
echo "--------------------------------------------------------------------------------"

response=$(curl -s -w "\n%{http_code}" \
  "https://api.airtable.com/v0/meta/bases" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo "✓ Can list bases"
    echo ""
    echo "Accessible bases:"
    echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    echo ""

    # Check if our base is in the list
    if echo "$body" | grep -q "$AIRTABLE_BASE_ID"; then
        echo "✓ Your base ($AIRTABLE_BASE_ID) IS in the accessible list!"
    else
        echo "✗ Your base ($AIRTABLE_BASE_ID) is NOT in the accessible list"
        echo ""
        echo "This means the token doesn't have access to this specific base."
        echo "Please add the base to your token at: https://airtable.com/create/tokens"
    fi
elif [ "$http_code" = "403" ]; then
    echo "⚠ Cannot list bases (missing schema.bases:read scope or no bases added)"
    echo ""
    echo "This is expected if you haven't added the 'schema.bases:read' scope."
    echo "However, you MUST add your specific base to the token's access list."
else
    echo "✗ Unexpected response (HTTP $http_code)"
    echo "$body"
fi

echo ""

# Test 3: Try to access the specific base
echo "Test 3: Attempting to access base tables..."
echo "--------------------------------------------------------------------------------"

response=$(curl -s -w "\n%{http_code}" \
  "https://api.airtable.com/v0/meta/bases/${AIRTABLE_BASE_ID}/tables" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
    echo "✓ SUCCESS! Can access base $AIRTABLE_BASE_ID"
    echo ""
    echo "Tables found:"
    echo "$body" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | nl
elif [ "$http_code" = "403" ]; then
    echo "✗ FORBIDDEN: Token doesn't have access to this base"
    echo ""
    echo "SOLUTION:"
    echo "1. Go to: https://airtable.com/create/tokens"
    echo "2. Find your token and click Edit"
    echo "3. Under 'Access', click 'Add a base'"
    echo "4. Select 'Foundation Grants Data' (ID: $AIRTABLE_BASE_ID)"
    echo "5. Click 'Save changes'"
    echo "6. Wait 10-20 seconds, then run this test again"
elif [ "$http_code" = "404" ]; then
    echo "✗ NOT FOUND: Base ID may be incorrect"
    echo ""
    echo "Please verify your Base ID. Open your base in Airtable and check the URL:"
    echo "https://airtable.com/[BASE_ID]/..."
else
    echo "✗ Unexpected error (HTTP $http_code)"
    echo "$body"
fi

echo ""
echo "================================================================================"
echo "REQUIRED TOKEN CONFIGURATION:"
echo "================================================================================"
echo ""
echo "Your token MUST have:"
echo "  1. Scopes:"
echo "     • data.records:read"
echo "     • data.records:write"
echo "     • schema.bases:read"
echo ""
echo "  2. Base Access:"
echo "     • Foundation Grants Data (ID: $AIRTABLE_BASE_ID)"
echo ""
echo "Configure at: https://airtable.com/create/tokens"
echo ""
echo "================================================================================"
