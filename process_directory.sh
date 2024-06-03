#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

stop_file="$SCRIPT_DIR/STOP_NOW"
if test -f "$stop_file"; then
        echo "STOP file exists, exiting!"
        exit 1
fi
dir_to_process="${1:-%}"

# autocommit would probably work fine, but added explicit transaction begin / commit just to be safe.
read -r -d '' QUERY << EOM
BEGIN;
UPDATE
	archived_dirs
SET
	processing_started=datetime('now','localtime')
WHERE dir_path IN (
    SELECT dir_path
	FROM archived_dirs
	WHERE processing_started IS NULL
        AND dir_path LIKE '$dir_to_process'
    ORDER BY dir_path
    LIMIT 1
)
RETURNING dir_path;
COMMIT;
EOM

set -e

dir="$(echo "$QUERY" | sqlite3 "$db")"

if [ -z "$dir" ]
then
      echo "no path to process"
      exit 1;
fi

# from: https://linuxhint.com/generate-random-string-bash/
password="$(cat /proc/sys/kernel/random/uuid)"
archive_file="$(mktemp)"

# https://news.ycombinator.com/item?id=21959517
# https://linuxconfig.org/how-to-create-compressed-encrypted-archives-with-tar-and-gpg
# https://linuxnightly.com/how-to-use-zstandard-compression-on-linux-with-commands/
tar --dereference --preserve-permissions -I 'zstd -16' -cf - "../$dir" | gpg --batch --yes -c --passphrase "$password" --cipher-algo AES256 > "$archive_file"

size="$(du -b "$archive_file" | cut -f1 -d$'\t')"
md5sum="$(md5sum "$archive_file" | cut -f1 -d ' ')"
gcp_dest="${gcp_bucket}/${dir}.tar.zst.gpg"

echo "UPDATE archived_dirs SET processing_completed=datetime('now','localtime'), archive_password='$password', archive_md5sum='$md5sum', archive_size_bytes=$size, archive_gcp_url='$gcp_dest'  WHERE dir_path = '$dir'" | sqlite3 "$db"

gsutil cp "$archive_file" "$gcp_dest"
rm "$archive_file"
echo "uploaded $gcp_dest ($size bytes)"
