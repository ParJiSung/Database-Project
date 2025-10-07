#!/usr/bin/env bash
set -euo pipefail

# Load env (DB_URL like mysql://user:pass@host:3306/dbname)
: "${DB_URL:?Set DB_URL env var, e.g. mysql://root:pass@127.0.0.1:3306/projectpizza}"

# parse DB_URL for mysql client (quick and dirty)
proto_removed="${DB_URL#mysql://}"
creds_host_db="${proto_removed%%\?*}"
userpass="${creds_host_db%@*}"
hostdb="${creds_host_db#*@}"
user="${userpass%%:*}"
pass="${userpass#*:}"
host="${hostdb%%/*}"
db="${hostdb#*/}"

mysql_cmd=(mysql -h "$host" -u "$user" "-p$pass" "$db" --default-character-set=utf8mb4)

echo "==> Running All_tables.sql"
"${mysql_cmd[@]}" < "$(dirname "$0")/../db/All_tables.sql"

echo "==> Running File2.sql"
"${mysql_cmd[@]}" < "$(dirname "$0")/../db/File2.sql"

echo "==> Running Tables&Data.sql"
"${mysql_cmd[@]}" < "$(dirname "$0")/../db/Tables&Data.sql"

echo "==> Creating views (app/sql/create_views.sql)"
"${mysql_cmd[@]}" < "$(dirname "$0")/../app/sql/create_views.sql"

echo "Done ✅"
