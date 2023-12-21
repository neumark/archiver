# What is this?
This is a set of scripts for archiving non-changing data (eg: family photos) in a GCP storage bucket.
Directories are compressed and encrypted prior to being uploaded.
Each archive is encrypted with a different password, which is stored in a SQLite db.
The DB itself is also encrypted with the `db_archive_password`.

**If you lose the `db_archive_password`, you lose all of your archives.**

## pros
* very cheap monthly fee per-Gb
* no vendor lockin (macos + linux tested)
* file-type agnostic, can store photos, videos, PDFs, whatever
* end-to-end encrypted
## cons
* it's just a pile of shell scripts 😅
* no friendly fat-client UI for restoring backups (like TimeMachine) or web UI for viewing them (like Google Photos or iCloud)
* no support for file versions / incremental backups (this is really archiving, not "backups" in the traditional sense)
* to view / extract a single file, the entire archive must be downloaded, and you have to know which archive to look in, as there's no index for which archive contains which files.
* requires some familiarity with unix to use (it's going to be challenging for my family to access these archives if I pass away unexpectedly).

# Setup

## Bucket creation
Be sure to create a single-region GCP Storage bucket in one of the [cheaper regions](https://cloud.google.com/storage/pricing) like `us-east1`.
The bucket's default storage class should be 'archive'.

## Dependencies
These scripts depend on `jq`, `python3`, `gpg`, `zstd`, `tee` and the GNU version of `tar` being installed (see the later note on running on MacOS).

## Configuration
Start by configuring `config.sh`. The `archive_name` can be anything you like.
Then, run the setup script:
```bash
./setup.sh
```

Finally, tweak `import_directories.sh` to find the right directories for archiving.

# Archiving directories

1. Add directories to archive by running `import_directories.sh`
2. Create and upload archives by running `process_directory.sh`. Optionally, a specific directory already queued by `import_directories.sh` may be specified, eg: `process_directory.sh 'peter/2015/2015-12-21'`.
3. Upload a new version of the encrypted sqlite3 db using `backup_db.sh`

# Extracting archives
```bash
./extract_archive.sh 'peter/2015/2015-10-20'
```

`extract_archive.sh` can be run from outside the `archiver` directory. It extracts to the current dir.

# MacOS
the script relies on gnu tar
```bash
brew install gnu-tar
PATH="$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$PATH" ./extract_archive.sh 'peter/2015/2015-12-21'
```

# Processing multiple directories

```bash
for i in {1..20}; do ./process_directory.sh ; done
```

Note that it's possible to run several parallel instances of `process_directory.sh`, but sqlite's locking is not very granular and the scripts will fail if they cannot aquire a lock on the DB.

# Stopping a bash `for` loop
```bash
touch STOP_NOW
```

# Querying interrupted uploads
start sqlite with `sqlite3 neumark_family_archive.sqlite3`, then:

```sql
select * from archived_dirs where processing_started is not NULL and processing_completed is NULL;
```

# Clearing interrupted uploads
start sqlite with `sqlite3 neumark_family_archive.sqlite3`, then:

```sql
update archived_dirs set processing_started = NULL where processing_completed is NULL;
```

# Verifying checksums
```bash
./for_each_dir.sh './verify_checksum.sh ' | tee -a verified.txt
```
