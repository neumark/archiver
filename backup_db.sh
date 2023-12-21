#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

set -e

# from: https://linuxhint.com/generate-random-string-bash/
password="$(cat "db_archive_password.txt")"
archive_file="$(mktemp)"

# https://news.ycombinator.com/item?id=21959517
# https://linuxconfig.org/how-to-create-compressed-encrypted-archives-with-tar-and-gpg
# https://linuxnightly.com/how-to-use-zstandard-compression-on-linux-with-commands/
tar --preserve-permissions -I 'zstd -12' -cf - "./" | gpg --batch --yes -c --passphrase "$password" --cipher-algo AES256 > "$archive_file"

gsutil cp -s standard "$archive_file" "$db_archive_url"
rm "$archive_file"
echo "uploaded $db_archive_url"
