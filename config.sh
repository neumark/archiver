#! /bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# --- BEGIN CONFIG VARIABLES ---
archive_name="neumark_family_archive"
gcp_bucket="gs://neumark_family_archive"
# --- END CONFIG VARIABLES ---

db="$SCRIPT_DIR/$archive_name.sqlite3"
db_archive_url="${gcp_bucket}/${archive_name}_db.tar.zst.gpg"
