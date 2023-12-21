#! /bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/config.sh"

date="$(date +"%Y-%m-%d")"
dir_list="${date}-directories"

# write csv file header
echo "dir_path" > "$dir_list"

# YYYY/YYYY-MM-DD style archive directories
find ../peter -mindepth 2 -maxdepth 2 -type d | cut -c4- >> "$dir_list"
find ../bence -mindepth 2 -maxdepth 2 -type d | cut -c4- >> "$dir_list"
find ../tenepi -mindepth 2 -maxdepth 2 -type d | cut -c4- >> "$dir_list"
find ../andi/ -mindepth 2 -maxdepth 2 -type d | cut -c4-  >> "$dir_list"
find ../eva -mindepth 2 -maxdepth 2 -type d | cut -c4- >> "$dir_list"
find ../napa -mindepth 2 -maxdepth 2 -type d | cut -c4- >> "$dir_list"
find ../papmari -mindepth 2 -maxdepth 2 -type d | cut -c4- >> "$dir_list"


# regi elkini felvetelek is very large, treat subdirs as separate archives
find ../neumark_csalad_kepek/2022/2022-08\ regi\ elkini\ felvetelek/ -mindepth 1 -maxdepth 1 -type d | cut -c4- >> "$dir_list"
# most content is from after 2000, these dirs are archive sized
find ../neumark_csalad_kepek -mindepth 2 -maxdepth 2 -not -path ../neumark_csalad_kepek/2022/2022-08\ regi\ elkini\ felvetelek -type d | cut -c4- >> "$dir_list"

# YYYY/ style archive dirs
find ../bachorecz/ -mindepth 1 -maxdepth 1 -type d | cut -c4- >> "$dir_list"
find ../gesztenye/ -mindepth 1 -maxdepth 1 -type d | cut -c4- >> "$dir_list"
find ../gyerekrajzok/ -mindepth 1 -maxdepth 1 -type d | cut -c4- >> "$dir_list"
find ../friends/ -mindepth 1 -maxdepth 1 -type d | cut -c4- >> "$dir_list"
find ../art/ -mindepth 1 -maxdepth 1 -type d | cut -c4- >> "$dir_list"

# import directories to staging table
# from: https://stackoverflow.com/a/27480453
echo -e ".separator "';'"\n.import $(pwd)/$dir_list $dir_list" | sqlite3 "$db"
# copy from staging table to archived_dirs
echo "INSERT OR IGNORE INTO archived_dirs(dir_path) SELECT dir_path from \"$dir_list\"" | sqlite3 "$db"
# drop staging table
echo "drop table \"$dir_list\"" | sqlite3 "$db"
# delete CSV file
rm "$dir_list"

