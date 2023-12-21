#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

result="$(echo -e ".mode json "';'"\nselect dir_path from archived_dirs where archive_password is not null" | sqlite3 "$db")"
cmd_prefix="$1"

echo "$result" | jq -r '.[]|[.dir_path] | @tsv' |
  while IFS=$'\t' read -r dir_path; do
      eval "$cmd_prefix\"$dir_path\""
  done
