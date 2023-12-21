#! /bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

set -e

DB_PASSWORD_FILE="$SCRIPT_DIR/db_archive_password.txt"

if [[ -f "$DB_PASSWORD_FILE" ]]; then
    echo "Refusing to overwrite $DB_PASSWORD_FILE"
    exit 1
fi

echo "$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n 1)" > "$DB_PASSWORD_FILE"

# don't need to check if DB exists, because sqlite will refuse to create an existing table.
total="$(echo -e "CREATE TABLE archived_dirs (dir_path varchar primary key, archive_md5sum varchar, archive_password varchar, archive_gcp_url varchar, archive_size_bytes integer, processing_started datetime, processing_completed datetime);" | sqlite3 "$db")"

echo "Master password and sqlite3 db created. Dont forget to create GCP Storage bucket!"
