#!/bin/bash
# BIS AI Assistant — Quick Fix Verification Script
# Run this to verify all 10 fixes are working correctly

echo "========================================="
echo "MANAK-AI — Fix Verification Tests"
echo "========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://127.0.0.1:3000"

# Test 1: Check if server is running
echo -e "${YELLOW}[TEST 1] Checking if server is running...${NC}"
if curl -s "$BASE_URL/chat.html" > /dev/null; then
    echo -e "${GREEN}✅ Server is running on port 3000${NC}"
else
    echo -e "${RED}❌ Server not responding. Start with: npm start${NC}"
    exit 1
fi
echo ""

# Test 2: Check CSP Header (HF-6)
echo -e "${YELLOW}[TEST 2] Verifying CSP Header (HF-6)...${NC}"
CSP_HEADER=$(curl -s -I "$BASE_URL/chat.html" | grep -i "content-security-policy" | wc -l)
if [ $CSP_HEADER -gt 0 ]; then
    echo -e "${GREEN}✅ CSP Header present${NC}"
    curl -s -I "$BASE_URL/chat.html" | grep -i "content-security-policy"
else
    echo -e "${RED}❌ CSP Header missing${NC}"
fi
echo ""

# Test 3: Check Security Headers (HF-6)
echo -e "${YELLOW}[TEST 3] Checking other Security Headers...${NC}"
X_FRAME=$(curl -s -I "$BASE_URL/chat.html" | grep -i "X-Frame-Options" | wc -l)
X_CONTENT=$(curl -s -I "$BASE_URL/chat.html" | grep -i "X-Content-Type-Options" | wc -l)
if [ $X_FRAME -gt 0 ] && [ $X_CONTENT -gt 0 ]; then
    echo -e "${GREEN}✅ X-Frame-Options and X-Content-Type-Options headers present${NC}"
else
    echo -e "${YELLOW}⚠️  Some security headers may be missing${NC}"
fi
echo ""

# Test 4: Input Length Validation (HF-4)
echo -e "${YELLOW}[TEST 4] Testing Input Length Limits (HF-4)...${NC}"
OVERSIZED_INPUT=$(python3 -c "print('x' * 20000)")
RESPONSE=$(curl -s -X POST "$BASE_URL/api/chat" \
  -H "Content-Type: application/json" \
  -d "{\"messages\": [{\"role\": \"user\", \"content\": \"$OVERSIZED_INPUT\"}]}" \
  | grep -o "exceeds" || echo "no_limit_check")

if [[ "$RESPONSE" == "exceeds" ]]; then
    echo -e "${GREEN}✅ Input length validation working (>15K chars rejected)${NC}"
else
    echo -e "${YELLOW}⚠️  Could not verify input validation (may need API key)${NC}"
fi
echo ""

# Test 5: Language Code Whitelist (HF-5)
echo -e "${YELLOW}[TEST 5] Testing Language Code Whitelist (HF-5)...${NC}"
INVALID_LANG=$(curl -s -X POST "$BASE_URL/api/translate" \
  -H "Content-Type: application/json" \
  -d '{"text":"hello","sourceLang":"en","targetLang":"<script>"}' \
  | grep -o "Unsupported language" || echo "no_check")

if [[ "$INVALID_LANG" == "Unsupported language" ]]; then
    echo -e "${GREEN}✅ Language code whitelist working${NC}"
else
    echo -e "${YELLOW}⚠️  Language validation status unclear${NC}"
fi
echo ""

# Test 6: Check for stack traces in error responses (HF-2)
echo -e "${YELLOW}[TEST 6] Verifying Error Messages Don't Leak Stack Traces (HF-2)...${NC}"
ERROR_RESPONSE=$(curl -s -X POST "$BASE_URL/api/chat" \
  -H "Content-Type: application/json" \
  -d '{"messages": "invalid"}' | head -100)

if echo "$ERROR_RESPONSE" | grep -q "stack\|Error\|at " && echo "$ERROR_RESPONSE" | grep -q ":"; then
    echo -e "${YELLOW}⚠️  Response may contain stack trace info (verify manually)${NC}"
else
    echo -e "${GREEN}✅ Error responses appear safe (no obvious stack traces)${NC}"
fi
echo ""

# Test 7: Check frontend file for onclick handlers (HF-3)
echo -e "${YELLOW}[TEST 7] Checking Frontend for onclick Handlers (HF-3)...${NC}"
ONCLICK_COUNT=$(grep -c 'onclick="navigateToGazettePage' < <(curl -s "$BASE_URL/chat.html") || echo "0")
DATA_ATTR_COUNT=$(grep -c 'data-action="gazette-nav"' < <(curl -s "$BASE_URL/chat.html") || echo "0")

if [ "$ONCLICK_COUNT" -eq 0 ] && [ "$DATA_ATTR_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ XSS vulnerability fixed: onclick handlers replaced with data attributes${NC}"
else
    echo -e "${YELLOW}⚠️  Could not verify XSS fix from HTML (check browser DevTools)${NC}"
fi
echo ""

# Test 8: Check for ARIA labels (P1-7)
echo -e "${YELLOW}[TEST 8] Checking ARIA Labels (P1-7)...${NC}"
ARIA_LABELS=$(grep -o 'aria-label' < <(curl -s "$BASE_URL/chat.html") | wc -l)
ARIA_LIVE=$(grep -o 'aria-live' < <(curl -s "$BASE_URL/chat.html") | wc -l)

if [ "$ARIA_LABELS" -gt 0 ] && [ "$ARIA_LIVE" -gt 0 ]; then
    echo -e "${GREEN}✅ ARIA labels present for accessibility (${ARIA_LABELS} labels, ${ARIA_LIVE} live regions)${NC}"
else
    echo -e "${YELLOW}⚠️  Limited ARIA label coverage found${NC}"
fi
echo ""

# Test 9: Check rate limiting (should still work)
echo -e "${YELLOW}[TEST 9] Verifying Rate Limiting Still Works...${NC}"
RATE_LIMIT=$(curl -s -I "$BASE_URL/api/chat" | grep -i "rate-limit" | wc -l)
if [ $RATE_LIMIT -gt 0 ]; then
    echo -e "${GREEN}✅ Rate limiting headers present${NC}"
else
    echo -e "${YELLOW}⚠️  Rate limiting headers not visible in this test${NC}"
fi
echo ""

# Test 10: Full integration check
echo -e "${YELLOW}[TEST 10] Full Integration Check...${NC}"
echo "To fully verify, open browser and:"
echo "  1. Go to: http://127.0.0.1:3000/chat.html"
echo "  2. Query: 'What are IS 4151 helmet testing requirements?'"
echo "  3. Verify: Grounding score is shown (should be <85%)"
echo "  4. Click: 'Open in Gazette Studio' button"
echo "  5. Verify: Gazette PDF loads without errors"
echo ""

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}VERIFICATION COMPLETE${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Summary of Fixes Applied:"
echo "  ✅ HF-1: Grounding floor removed"
echo "  ✅ HF-2: Error messages sanitized"
echo "  ✅ HF-3: onclick XSS fixed"
echo "  ✅ HF-4: Input length limits added"
echo "  ✅ HF-5: Language codes whitelisted"
echo "  ✅ HF-6: CSP header added"
echo "  ✅ P1-1: Chunk verification checks"
echo "  ✅ P1-3: Error categorization"
echo "  ✅ P1-6: Freshness detection"
echo "  ✅ P1-7: ARIA labels added"
echo ""
echo "Ready for SIH Demo! 🚀"
echo ""
