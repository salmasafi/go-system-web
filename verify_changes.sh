#!/bin/bash

# Script to verify all changes for removing different_price concept

echo "🔍 Verifying changes for removing different_price concept..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter
ISSUES=0

echo "📋 Checking for remaining references..."
echo ""

# Check for differentPrice in Dart files
echo "1️⃣ Checking for 'differentPrice' in Dart files..."
if grep -r "differentPrice" lib/ --include="*.dart" | grep -v "// Note: differentPrice removed" | grep -v "differentPrice removed in migration"; then
    echo -e "${RED}❌ Found remaining differentPrice references${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✅ No differentPrice references found${NC}"
fi
echo ""

# Check for productPriceId in Dart files
echo "2️⃣ Checking for 'productPriceId' in Dart files..."
if grep -r "productPriceId" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${RED}❌ Found remaining productPriceId references${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✅ No productPriceId references found${NC}"
fi
echo ""

# Check for product_price_id in Dart files
echo "3️⃣ Checking for 'product_price_id' in Dart files..."
if grep -r "product_price_id" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${RED}❌ Found remaining product_price_id references${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✅ No product_price_id references found${NC}"
fi
echo ""

# Check for VariationModel in Dart files
echo "4️⃣ Checking for 'VariationModel' in Dart files..."
if grep -r "VariationModel" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${RED}❌ Found remaining VariationModel references${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✅ No VariationModel references found${NC}"
fi
echo ""

# Check for ProductPrice class in Dart files
echo "5️⃣ Checking for 'class ProductPrice' in Dart files..."
if grep -r "class ProductPrice" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${RED}❌ Found remaining ProductPrice class${NC}"
    ISSUES=$((ISSUES+1))
else
    echo -e "${GREEN}✅ No ProductPrice class found${NC}"
fi
echo ""

# Check for PriceVariation in Dart files
echo "6️⃣ Checking for 'PriceVariation' in Dart files..."
if grep -r "PriceVariation" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Found PriceVariation references (may need review)${NC}"
else
    echo -e "${GREEN}✅ No PriceVariation references found${NC}"
fi
echo ""

# Check migration file exists
echo "7️⃣ Checking migration file..."
if [ -f "supabase/migrations/014_remove_different_price.sql" ]; then
    echo -e "${GREEN}✅ Migration file exists${NC}"
else
    echo -e "${RED}❌ Migration file not found${NC}"
    ISSUES=$((ISSUES+1))
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Ready to proceed.${NC}"
else
    echo -e "${RED}❌ Found $ISSUES issue(s). Please review.${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📝 Next steps:"
echo "1. Review any remaining issues above"
echo "2. Run: cd supabase && supabase db push"
echo "3. Run: flutter clean && flutter pub get"
echo "4. Run: flutter run"
echo "5. Test all features thoroughly"
echo ""

exit $ISSUES
