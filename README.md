## NAME

    compare_two_files.pl

## VERSION

Documentation for `compare_two_files.pl` version 1.1

## SYNOPSIS

    compare_two_files.pl [--union|--intersection|--one|--two|--silent]
    [--help] [--man] FILE1 FILE2

## DESCRIPTION

Compares two lists in two separate files.

Shows the results interactively, or, if the `--silent` option is used, silently.

Unique values in the first and second files can be extracted using the
`-1`, `--one`, or `-2`, `--two` options, respectively, as well as the
intersection (`--intersection`), and union (`--union`).

## OPTIONS

Mandatory arguments to long options are mandatory for short options too

    -u, --union
            Get those items which appear at least once in either FILE1 and
            FILE2 (their *union*).

    -i, --intersection
            Get those items which appear at least once in both FILE1 and
            FILE2 (their *intersection*).

    -1, -o, --one
            Print the *unique* values in list from FILE1.

    -2, -t, --two
            Print the *unique* values in list from FILE2.

    -h, --help
            Prints *help* message and exits.

    -m, --man
            Displays the *manual* page.

    FILEN   FILE, and FILE2 should contain lists to be compared (one in each
            file).

## USAGE

Examples:

    compare_two_files.pl FILE1 FILE2
    compare_two_files.pl --silent FILE1 FILE2
    compare_two_files.pl --union FILE1 FILE2
    compare_two_files.pl --intersection FILE1 FILE2
    compare_two_files.pl -1 FILE1 FILE2
    compare_two_files.pl -2 FILE1 FILE2

## AUTHOR

Written by Johan A. A. Nylander

## DEPENDENCIES

Perl modules from CRAN: File::Slurp, List::Compare.

## DOWNLOAD

<https://github.com/nylander/compare_two_files>

## LICENSE AND COPYRIGHT

Copyright (c) 2009-2022 Johan Nylander. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
Public License for more details. <http://www.gnu.org/copyleft/gpl.html>

