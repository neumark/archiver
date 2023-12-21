#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

set -e
password="$(cat "$SCRIPT_DIR/db_archive_password.txt")"
archive_file="$(mktemp)"
gsutil cp "$db_archive_url" "$archive_file"
# https://linuxconfig.org/how-to-create-compressed-encrypted-archives-with-tar-and-gpg
gpg --batch --yes --passphrase "$password" -d "$archive_file" | tar --use-compress-program zstd -xvf -
rm "$archive_file"
