#!/bin/bash
# List all bases accessible by this token

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "================================================================================"
echo "LISTING ALL BASES ACCESSIBLE BY YOUR TOKEN"
echo "================================================================================"
echo ""

# Try to list all bases this token can access
response=$(curl -s -w "\n%{http_code}" \
  "https://api.airtable.com/v0/meta/bases" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo "HTTP Status: $http_code"
echo ""

if [ "$http_code" = "200" ]; then
    echo "✓ SUCCESS! Here are the bases your token can access:"
    echo ""

    # Parse and display bases
    echo "$body" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    bases = data.get('bases', [])
    if not bases:
        print('  ⚠ No bases found! Your token might not have any bases added.')
    else:
        for i, base in enumerate(bases, 1):
            print(f'{i}. Name: {base.get(\"name\", \"Unknown\")}')
            print(f'   ID: {base.get(\"id\", \"Unknown\")}')
            print(f'   Permission Level: {base.get(\"permissionLevel\", \"Unknown\")}')
            print()
except:
    print('Could not parse response')
    print(sys.stdin.read())
" 2>/dev/null || echo "$body"

    echo ""
    echo "Your .env file is configured for:"
    echo "  Base ID: $AIRTABLE_BASE_ID"
    echo ""
    echo "Check if this ID matches one of the bases listed above!"

elif [ "$http_code" = "403" ]; then
    echo "✗ 403 Forbidden - Cannot list bases"
    echo ""
    echo "This might mean:"
    echo "  1. Token doesn't have 'schema.bases:read' scope"
    echo "  2. Token has no bases added to its access list"
    echo ""
    echo "Let's try to get token info instead..."
    echo ""

    # Try whoami endpoint
    response2=$(curl -s -w "\n%{http_code}" \
      "https://api.airtable.com/v0/meta/whoami" \
      -H "Authorization: Bearer ${AIRTABLE_API_KEY}")

    http_code2=$(echo "$response2" | tail -n1)
    body2=$(echo "$response2" | sed '$d')

    if [ "$http_code2" = "200" ]; then
        echo "✓ Token is valid! Token info:"
        echo "$body2" | python3 -m json.tool 2>/dev/null || echo "$body2"
    else
        echo "✗ Cannot get token info (HTTP $http_code2)"
        echo "$body2"
    fi

else
    echo "✗ Unexpected error (HTTP $http_code)"
    echo "$body"
fi

echo ""
echo "================================================================================"
echo "NEXT STEP:"
echo "================================================================================"
echo ""
echo "If the base ID $AIRTABLE_BASE_ID is NOT in the list above,"
echo "then the token was configured with the wrong base!"
echo ""
echo "Solution:"
echo "  1. Go to: https://airtable.com/create/tokens"
echo "  2. Find your token and click 'Edit'"
echo "  3. Under 'Access', remove any wrong bases"
echo "  4. Click 'Add a base' and select the base with ID: $AIRTABLE_BASE_ID"
echo "  5. Save changes and test again"
echo ""
