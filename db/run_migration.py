"""
Quick script to run migration - accepts password as argument
Usage: python db/run_migration.py YOUR_PASSWORD
"""
import os
import sys
from pathlib import Path

# Force UTF-8 output
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Project ref from .env.dev
PROJECT_REF = "vazhgunhcjdwlkbslroc"

print("="*60)
print("AI LMS - DATABASE MIGRATION")
print("="*60)

# Get password from command line argument or environment variable
db_password = None
if len(sys.argv) > 1:
    db_password = sys.argv[1]
else:
    # Try environment variable - key is '1TzdzODq2DICHpfY', value is the password
    db_password = os.environ.get('SUPABASE_DB_PASSWORD') or os.environ.get('1TzdzODq2DICHpfY')

if not db_password:
    print("\nUsage: python db/run_migration.py YOUR_PASSWORD")
    print("\nOr set SUPABASE_DB_PASSWORD environment variable")
    sys.exit(1)

conn_str = f"postgresql://postgres:{db_password}@db.{PROJECT_REF}.supabase.co:5432/postgres"

# Read migration file
migration_file = Path(__file__).parent / "16_sync_schema_with_sql_flow_decisions.sql"
with open(migration_file, 'r', encoding='utf-8') as f:
    migration_sql = f.read()

print("\nConnecting and running migration...")

try:
    import psycopg2
    conn = psycopg2.connect(conn_str)
    conn.autocommit = True
    cursor = conn.cursor()

    # Split by semicolon and execute each statement
    statements = [s.strip() for s in migration_sql.split(';') if s.strip() and not s.strip().startswith('--')]

    success_count = 0
    error_count = 0

    for i, stmt in enumerate(statements, 1):
        try:
            cursor.execute(stmt)
            print(f"  OK [{i}/{len(statements)}]")
            success_count += 1
        except Exception as e:
            print(f"  FAIL [{i}/{len(statements)}]: {e}")
            error_count += 1

    cursor.close()
    conn.close()

    print("\n" + "="*60)
    print(f"MIGRATION COMPLETE! ({success_count} OK, {error_count} errors)")
    print("="*60)

except Exception as e:
    print(f"\nConnection error: {e}")
    sys.exit(1)
