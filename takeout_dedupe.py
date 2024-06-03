import sys
from dataclasses import dataclass
import pprint
import json
from typing import Optional
import os
import hashlib

@dataclass
class TocEntry:
    takeout_id: str
    relpath: str
    size_bytes: int
    checksum: Optional[str] = None

test_toc_lines = """
903 ./2021-09-09/Google Photos/Photos from 2018/IMG_0799.JPG.json
772377 ./2021-09-09/Google Photos/Photos from 2018/IMG_0801.JPG
255505 ./2021-09-09/Google Photos/Photos from 2018/IMG_0557.JPG
954 ./2021-09-09/Google Photos/Photos from 2018/IMG_0556.JPG.json
1813 ./2021-09-09/Google Photos/Photos from 2018/IMG_2675.MOV.json
1769 ./2021-09-09/Google Photos/Photos from 2018/IMG_2674.MOV.json
688443 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_145535110.jpg
917 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_145530318.jpg.json
919 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_150011155.jpg.json
902 ./2021-09-09/Google Photos/Photos from 2018/IMG_0790.JPG.json
920 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_145353546.jpg.json
900 ./2021-09-09/Google Photos/Photos from 2018/IMG_0789.JPG.json
920 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_145351378.jpg.json
920 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_145328252.jpg.json
920 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_145320767.jpg.json
902 ./2021-09-09/Google Photos/Photos from 2018/IMG_0787.JPG.json
902 ./2021-09-09/Google Photos/Photos from 2018/IMG_0786.JPG.json
395094 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_144137575.jpg
920 ./2021-09-09/Google Photos/Photos from 2018/IMG_20180826_144130487.jpg.json
""".strip()

def parse_toc_line(toc_line):
    (size, rawpath) = toc_line.strip().split(" ", 1)
    # remove leadin './' if prsent
    if rawpath.startswith('./'):
        rawpath = rawpath[2:]
    (takeout_id, relpath) = rawpath.split("/", 1)
    return TocEntry(
        takeout_id=takeout_id,
        size_bytes = int(size),
        relpath=relpath)

def parse_toc(toc_lines):
    return [parse_toc_line(line) for line in toc_lines]

def test_toc_json():
    lines = test_toc_lines.split('\n')
    parsed_lines = parse_toc(lines)
    serialized = json.dumps(parsed_lines[0].__dict__)
    assert TocEntry(**json.loads(serialized)) == parsed_lines[0]

def get_checksum(filename):
    #with open(filename, "rb") as f:
    #    digest = hashlib.file_digest(f, "md5")
    #    return digest.hexdigest()
    try:
        with open(filename, "rb") as f:
            file_hash = hashlib.blake2b()
            while chunk := f.read(8192):
                file_hash.update(chunk)
            return file_hash.hexdigest()
    except FileNotFoundError:
        return None

def test_toc_parse():
    lines = test_toc_lines.split('\n')
    parsed_lines = parse_toc(lines)
    assert parsed_lines == [
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0799.JPG.json', size_bytes=903),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0801.JPG', size_bytes=772377),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0557.JPG', size_bytes=255505),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0556.JPG.json', size_bytes=954),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_2675.MOV.json', size_bytes=1813),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_2674.MOV.json', size_bytes=1769),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_145535110.jpg', size_bytes=688443),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_145530318.jpg.json', size_bytes=917),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_150011155.jpg.json', size_bytes=919),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0790.JPG.json', size_bytes=902),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_145353546.jpg.json', size_bytes=920),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0789.JPG.json', size_bytes=900),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_145351378.jpg.json', size_bytes=920),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_145328252.jpg.json', size_bytes=920),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_145320767.jpg.json', size_bytes=920),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0787.JPG.json', size_bytes=902),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_0786.JPG.json', size_bytes=902),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_144137575.jpg', size_bytes=395094),
        TocEntry(takeout_id='2021-09-09', relpath='Google Photos/Photos from 2018/IMG_20180826_144130487.jpg.json', size_bytes=920)]

def get_toc_dict(filename):
    with open(filename, "r") as f:
        parsed_lines = parse_toc(f.readlines())
        return {l.relpath: l for l in parsed_lines}

def main():
    old_takeout = sys.argv[1]
    new_takeout = sys.argv[2]
    old_toc_dict = get_toc_dict(old_takeout)
    new_toc_dict = get_toc_dict(new_takeout)
    print(f"# old takeout toc: {old_takeout} ({len(old_toc_dict)} files) new takeout toc: {new_takeout} ({len(new_toc_dict)} files)")
    # iterate through new toc, looking for matches with old
    for new_toc_entry in new_toc_dict.values():
        if new_toc_entry.relpath in old_toc_dict and new_toc_entry.size_bytes == old_toc_dict[new_toc_entry.relpath].size_bytes:
            old_toc_entry = old_toc_dict[new_toc_entry.relpath]
            old_file_path = os.path.join(old_takeout[:-4], old_toc_entry.relpath)
            new_file_path = os.path.join(new_takeout[:-4], new_toc_entry.relpath)
            old_toc_entry.checksum = get_checksum(old_file_path)
            new_toc_entry.checksum = get_checksum(new_file_path)
            if old_toc_entry.checksum == new_toc_entry.checksum:
                print(f"# checksum match {old_file_path} {new_file_path} {old_toc_entry.checksum}, duplicate found")
                print(f"rm '{new_file_path}'")
            else:
                print(f"# checksum mismatch for {new_toc_entry.relpath}")


if __name__ == "__main__":
    if os.environ.get('TEST', None) == "true":
        test_toc_parse()
        test_toc_json()
    else:
        main()
