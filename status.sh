#! /bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

set -e

total="$(echo -e "select count(0) from archived_dirs" | sqlite3 "$db")"
processed="$(echo -e "select count(0) from archived_dirs where archive_gcp_url is not null" | sqlite3 "$db")"
size="$(echo -e "select sum(archive_size_bytes)/(1024*1024*1024) from archived_dirs" | sqlite3 "$db")"

echo "uploaded $processed ($size Gb) of $total archive directories"
