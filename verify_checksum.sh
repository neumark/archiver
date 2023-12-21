#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

dir="$1"
result="$(echo -e ".mode json "';'"\nselect archive_md5sum, archive_gcp_url from archived_dirs where dir_path='$dir' and archive_password is not null" | sqlite3 "$db")"

md5_from_db="$(echo "$result" | jq -r '.[0].archive_md5sum')"
gs_url="$(echo "$result" | jq -r '.[0].archive_gcp_url')"

md5_from_gcp="$(gsutil stat "$gs_url" | grep md5 | cut -d : -f 2 | xargs python3 decode_gsutil_md5.py)"

if [ "$md5_from_db" = "$md5_from_gcp" ]; then
      echo "$dir: OK - MD5 CHECKSUM MATCH"
else
      echo "$dir: FAIL - MD5 CHECKSUM MISMATCH"
fi
