#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

dir="$1"

result="$(echo -e ".mode json "';'"\nselect archive_password, archive_gcp_url from archived_dirs where dir_path='$dir' and archive_password is not null" | sqlite3 "$db")"
rowcount="$(echo "$result" | jq '. | length')"

if [[ $rowcount -eq 1 ]]
then
  echo "exists"
  password="$(echo "$result" | jq -r '.[0].archive_password')"
  gcp_url="$(echo "$result" | jq -r '.[0].archive_gcp_url')"
  archive_file="archive.tar.zstd.gpg"
  gsutil cp "$gcp_url" "$archive_file"
  # https://linuxconfig.org/how-to-create-compressed-encrypted-archives-with-tar-and-gpg
  gpg --batch --yes --passphrase "$password" -d "$archive_file" | tar --use-compress-program zstd -xvf -
  rm "$archive_file"
else
  echo "not found"
fi


