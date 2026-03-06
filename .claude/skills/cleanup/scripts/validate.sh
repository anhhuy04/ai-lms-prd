#!/bin/bash
# Cleanup Skill — Validation Script
# Verifies cleanup was successful after temp files removal

echo "=== Cleanup Validation ==="
echo ""

# Check for temp .md files (should NOT exist)
echo "1. Checking for temp .md files in root..."
temp_md_files=$(ls *.md 2>/dev/null | grep -v "^README" | grep -v "^CHANGELOG")
if [ -z "$temp_md_files" ]; then
    echo "   ✅ No temp .md files found"
else
    echo "   ⚠️  Found temp .md files:"
    echo "$temp_md_files"
fi

# Check for debug logs
echo ""
echo "2. Checking for debug logs..."
debug_logs=$(ls debug_*.log 2>/dev/null)
if [ -z "$debug_logs" ]; then
    echo "   ✅ No debug logs found"
else
    echo "   ⚠️  Found debug logs:"
    echo "$debug_logs"
fi

# Check for temp files
echo ""
echo "3. Checking for .tmp files..."
tmp_files=$(ls *.tmp 2>/dev/null)
if [ -z "$tmp_files" ]; then
    echo "   ✅ No .tmp files found"
else
    echo "   ⚠️  Found .tmp files:"
    echo "$tmp_files"
fi

# Check for experiment dart files
echo ""
echo "4. Checking for experiment dart files..."
exp_dart=$(ls experiment_*.dart draft_*.dart 2>/dev/null)
if [ -z "$exp_dart" ]; then
    echo "   ✅ No experiment/draft dart files found"
else
    echo "   ⚠️  Found experiment/draft dart files:"
    echo "$exp_dart"
fi

# Verify important files exist
echo ""
echo "5. Verifying important files exist..."
important=("README.md" ".claude/CLAUDE.md" "memory-bank/README.md")
for file in "${important[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing!"
    fi
done

# Summary
echo ""
echo "=== Validation Complete ==="
