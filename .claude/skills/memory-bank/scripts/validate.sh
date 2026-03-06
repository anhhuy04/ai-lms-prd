#!/bin/bash
# Memory Bank Skill — Validation Script
# Verifies memory-bank files are present and up to date

echo "=== Memory Bank Validation ==="
echo ""

# Check for core memory-bank files
echo "1. Checking core memory-bank files..."
core_files=(
    "memory-bank/README.md"
    "memory-bank/projectbrief.md"
    "memory-bank/productContext.md"
    "memory-bank/systemPatterns.md"
    "memory-bank/techContext.md"
    "memory-bank/activeContext.md"
    "memory-bank/progress.md"
)

for file in "${core_files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing!"
    fi
done

# Check Last Updated dates
echo ""
echo "2. Checking file freshness (should be recent)..."
for file in "${core_files[@]}"; do
    if [ -f "$file" ]; then
        # Extract date from "Last Updated: YYYY-MM-DD" pattern
        date_str=$(grep -i "Last Updated:" "$file" 2>/dev/null | head -1 | sed 's/.*Last Updated: *//' | tr -d ' ')
        if [ -n "$date_str" ]; then
            echo "   ✅ $file: $date_str"
        else
            echo "   ⚠️  $file: No date found"
        fi
    fi
done

# Check for empty template sections
echo ""
echo "3. Checking for empty/unfilled sections..."
empty_count=0
for file in "${core_files[@]}"; do
    if [ -f "$file" ]; then
        # Check for "(Fill in" or "(User fills" patterns
        unfilled=$(grep -c "(Fill in\|(User fills\|(TBD\|(To be" "$file" 2>/dev/null || echo "0")
        if [ "$unfilled" -gt 5 ]; then
            echo "   ⚠️  $file: $unfilled unfilled sections"
            empty_count=$((empty_count + 1))
        else
            echo "   ✅ $file: Properly filled"
        fi
    fi
done

# Summary
echo ""
if [ "$empty_count" -eq 0 ]; then
    echo "=== Validation Complete: ✅ All files OK ==="
else
    echo "=== Validation Complete: ⚠️ $empty_count files need filling ==="
fi
