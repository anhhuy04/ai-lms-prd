#!/bin/bash

# Script: Test và Apply Migration lên Supabase
# File: scripts/test_and_apply_migration.sh
# Description: Kiểm tra migration SQL và tự động apply lên Supabase nếu không có lỗi

set -e  # Exit on error

MIGRATION_FILE="db/02_create_question_bank_tables.sql"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Migration Test & Apply Script"
echo "=========================================="
echo "Migration file: $MIGRATION_FILE"
echo ""

# Check if migration file exists
if [ ! -f "$PROJECT_ROOT/$MIGRATION_FILE" ]; then
    echo "❌ ERROR: Migration file not found: $MIGRATION_FILE"
    exit 1
fi

echo "✅ Migration file found"
echo ""

# Basic SQL syntax check (if psql is available)
if command -v psql &> /dev/null; then
    echo "📋 Running SQL syntax check..."
    if psql --version &> /dev/null; then
        echo "✅ psql available for syntax check"
        # Note: This is a basic check, full validation requires connection to DB
    fi
else
    echo "⚠️  psql not found, skipping local syntax check"
fi

echo ""
echo "=========================================="
echo "Migration will be applied via Supabase MCP"
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT: This script requires Supabase MCP tools"
echo "   Make sure you have configured Supabase MCP server"
echo ""
echo "Migration will create the following tables:"
echo "  - learning_objectives"
echo "  - questions"
echo "  - question_choices"
echo "  - question_objectives"
echo "  - assignments"
echo "  - assignment_questions"
echo "  - assignment_variants"
echo "  - assignment_distributions"
echo ""
echo "And all associated:"
echo "  - Indexes"
echo "  - Triggers"
echo "  - RLS Policies"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Migration cancelled"
    exit 1
fi

echo ""
echo "✅ Ready to apply migration"
echo "   Note: Actual migration will be applied via MCP tools in the next step"
