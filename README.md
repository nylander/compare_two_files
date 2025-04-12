# Compare two files

## Description

This script compares two lists in separate files and provides options to compute
their union, intersection, or unique items in each file.

Prints to stdout (options `-u`, `-i`, `-1`, `-2`) or to files (options `-n`, `-s`).

Default is to be interactive (use `-n` to be non-interactive).

## Usage

    $ compare_two_files.pl [--union|--intersection|--one|--two|--silent] [--help] FILE1 FILE2

## Options

`-u`, `--union`        --- Print the union of items in FILE1 and FILE2 to stdout

`-i`, `--intersection` --- Print the intersection of items in FILE1 and FILE2 to stdout

`-1`, `--one`          --- Print items unique in FILE1 to stdout

`-2`, `--two`          --- Print items unique in FILE2 to stdout

`-n`, `--noverbose`    --- Run in silent mode (write results to files)

`-s`, `--silent`       --- Same as `-n` (for backwards compatibility)

`-h`, `--help`         --- Print this help message and exit

`-V`, `--version`      --- Print software version

## Examples

    $ compare_two_files.pl FILE1 FILE2
    $ compare_two_files.pl --noverbose FILE1 FILE2
    $ compare_two_files.pl --union FILE1 FILE2
    $ compare_two_files.pl --intersection FILE1 FILE2
    $ compare_two_files.pl --one FILE1 FILE2

## Download

<https://github.com/nylander/compare_two_files>

## License and Copyright

Copyright (c) 2008-2022 Johan Nylander. All rights reserved.

[MIT Licence](LICENSE)

