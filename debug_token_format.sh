#!/bin/bash
# Debug: Show exact token format and test character-by-character

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "================================================================================"
echo "TOKEN FORMAT DEBUG"
echo "================================================================================"
echo ""

echo "1. Token loaded from .env file:"
echo "   Length: ${#AIRTABLE_API_KEY} characters"
echo "   First 20 chars: ${AIRTABLE_API_KEY:0:20}"
echo "   Last 10 chars: ...${AIRTABLE_API_KEY: -10}"
echo ""

# Check for common issues
if [[ $AIRTABLE_API_KEY == *$'\r'* ]]; then
    echo "   ⚠ WARNING: Token contains carriage return (Windows line ending)"
fi

if [[ $AIRTABLE_API_KEY == *' '* ]]; then
    echo "   ⚠ WARNING: Token contains spaces"
fi

if [[ $AIRTABLE_API_KEY != pat* ]]; then
    echo "   ⚠ WARNING: Token doesn't start with 'pat'"
fi

echo ""
echo "2. Token structure analysis:"
if [[ $AIRTABLE_API_KEY == *.* ]]; then
    prefix="${AIRTABLE_API_KEY%%.*}"
    suffix="${AIRTABLE_API_KEY#*.}"
    echo "   ✓ Token has correct format (prefix.suffix)"
    echo "   Prefix: $prefix (${#prefix} chars)"
    echo "   Suffix: ${suffix:0:10}...${suffix: -10} (${#suffix} chars)"
else
    echo "   ✗ Token doesn't contain a dot (.)"
    echo "   This is WRONG - valid tokens are: patXXXXX.YYYYYY..."
fi

echo ""
echo "3. Testing API with this exact token:"
echo "--------------------------------------------------------------------------------"

# Test with very verbose output
curl -v "https://api.airtable.com/v0/meta/whoami" \
  -H "Authorization: Bearer ${AIRTABLE_API_KEY}" \
  2>&1 | grep -E "(HTTP|Authorization|< |access)"

echo ""
echo "================================================================================"
echo ""
echo "If you see 'HTTP/2 403' above, the token is being rejected."
echo ""
echo "NEXT STEPS:"
echo "1. Verify the token in your Airtable account still exists"
echo "2. Try deleting this token and creating a completely new one"
echo "3. When copying the new token, make sure you copy the ENTIRE string"
echo "   (Should be about 85-90 characters total)"
echo ""
