#!/usr/bin/env perl

#=============================================================
#         FILE:  compare_two_files.pl
#        USAGE:  ./compare_two_files.pl [options] FILE1 FILE2
#  DESCRIPTION:  Compares two lists in two separate files.
#      CREATED:  02 Nov 2008
#     REVISION:  12 Apr 2025
#=============================================================

use strict;
use warnings;
use File::Basename;
use Getopt::Long;

my $VERSION = '2.0';
my $noverbose = 0; # default is interactive
my ($union, $intersection, $unique1, $unique2);

sub print_help {
    print <<'END_HELP';
Usage: compare_two_files.pl [--union|--intersection|--one|--two|--silent] [--help] FILE1 FILE2

Options:
  -u, --union         Print the union of items in FILE1 and FILE2 to stdout
  -i, --intersection  Print the intersection of items in FILE1 and FILE2 to stdout
  -1, --one           Print items unique in FILE1 to stdout
  -2, --two           Print items unique in FILE2 to stdout
  -n, --noverbose     Run in silent mode (write results to files)
  -s, --silent        Same as noverbose (for backwards compatibility)
  -h, --help          Print this help message and exit
  -V, --version       Print software version

Description:
This script compares two lists in separate files and provides options to compute
their union, intersection, or unique items in each file.
Prints to stdout (options -u, -i, -1, -2) or to files (options -n, -s).
Default is to be interactive (use -n to be non-interactive).

Examples:
  compare_two_files.pl FILE1 FILE2
  compare_two_files.pl --noverbose FILE1 FILE2
  compare_two_files.pl --union FILE1 FILE2
  compare_two_files.pl --intersection FILE1 FILE2
  compare_two_files.pl --one FILE1 FILE2

END_HELP
    exit(0);
}

sub read_file_into_array {
    my ($filename) = @_;
    open my $FH, '<', $filename or die "could not open file '$filename': $!";
    my @lines = <$FH>;
    chomp @lines;
    close $FH;
    return @lines;
}

sub compute_set_operations {
    my ($list1_ref, $list2_ref) = @_;
    my %set1           = map {$_ => 1} @$list1_ref;
    my %set2           = map {$_ => 1} @$list2_ref;
    my @union          = keys %{{%set1, %set2}};
    my @intersection   = grep {$set2{$_}} keys %set1;
    my @first_only     = grep {!$set2{$_}} keys %set1;
    my @second_only    = grep {!$set1{$_}} keys %set2;
    my @symmetric_diff = (@first_only, @second_only);
    return (\@union, \@intersection, \@first_only, \@second_only, \@symmetric_diff);
}

sub prompt_user {
    my ($prompt_string, $default_value) = @_;
    print $prompt_string, "[", $default_value, "]: ";
    $| = 1; # force flush after print
    my $response = <STDIN>;
    chomp $response;
    return $response ? $response : $default_value;
}

sub check_file_exists {
    my ($filename) = @_;
    if (-e $filename) {
        die "Error: File '$filename' exists. Cowardly refusing to overwrite; exiting.\n";
    }
}

GetOptions(
    'noverbose|silent' => \$noverbose,
    'u|union'          => \$union,
    'i|intersection'   => \$intersection,
    '1|one'            => \$unique1,
    '2|two'            => \$unique2,
    'h|help'           => sub {print_help();},
    'V|version'        => sub {print "$VERSION\n"; exit 0;},
) or die "ERROR: Invalid options. Try $0 --help for more info.\n";

die "Input error. Try $0 --help for more info\n" unless (@ARGV == 2);

my $first_file = shift(@ARGV);
my $second_file = shift(@ARGV);

my @first_list = read_file_into_array($first_file);
my @second_list = read_file_into_array($second_file);
my ($union_ref, $isect_ref, $first_only_ref, $second_only_ref, $sym_diff_ref)
    = compute_set_operations(\@first_list, \@second_list);

if ($union) {
    print STDOUT "$_\n" for sort @$union_ref;
    exit(0);
}
elsif ($intersection) {
    print STDOUT "$_\n" for sort @$isect_ref;
    exit(0);
}
elsif ($unique1) {
    print STDOUT "$_\n" for sort @$first_only_ref;
    exit(0);
}
elsif ($unique2) {
    print STDOUT "$_\n" for sort @$second_only_ref;
    exit(0);
}

my $ff = basename($first_file);
my $sf = basename($second_file);
my $first_unique = $ff . ".unique";
my $second_unique = $sf . ".unique";
my $first_second_intersect = $ff . "." . $sf . ".intersection";

if ($noverbose) {
    check_file_exists($first_unique);
    open my $FH1, '>', $first_unique or die "Could not write to '$first_unique': $!";
    print $FH1 "$_\n" for sort @$first_only_ref;
    close $FH1;

    check_file_exists($second_unique);
    open my $FH2, '>', $second_unique or die "Could not write to '$second_unique': $!";
    print $FH2 "$_\n" for sort @$second_only_ref;
    close $FH2;

    check_file_exists($first_second_intersect);
    open my $FH3, '>', $first_second_intersect or die "Could not write to '$first_second_intersect': $!";
    print $FH3 "$_\n" for sort @$isect_ref;
    close $FH3;
}
else {
    print STDERR "\nComparing '$first_file' with '$second_file':\n\n";
    print STDERR " total number of unique items (union): ", scalar(@$union_ref), "\n";
    print STDERR " found in '$first_file' only: ", scalar(@$first_only_ref), "\n";
    print STDERR " found in '$second_file' only: ", scalar(@$second_only_ref), "\n";
    print STDERR " found in both (intersection): ", scalar(@$isect_ref), "\n\n";

    my $query = prompt_user("\nUnique values in '$first_file':\n Write to file '$first_unique' (F) or to screen (S)? ", "S");
    if ($query =~ /F/i) {
        check_file_exists($first_unique);
        open my $FH, '>', $first_unique or die "Could not write to '$first_unique': $!";
        print $FH "$_\n" for sort @$first_only_ref;
        close $FH;
    }
    else {
        print "$_\n" for sort @$first_only_ref;
    }

    $query = prompt_user("\nUnique values in '$second_file':\n Write to file '$second_unique' (F) or to screen (S)? ", "S");
    if ($query =~ /F/i) {
        check_file_exists($second_unique);
        open my $FH, '>', $second_unique or die "Could not write to '$second_unique': $!";
        print $FH "$_\n" for sort @$second_only_ref;
        close $FH;
    }
    else {
        print "$_\n" for sort @$second_only_ref;
    }

    $query = prompt_user("\nShared values (intersection) in '$first_file' and '$second_file':\n Write to file '$first_second_intersect' (F) or to screen (S)? ", "S");
    if ($query =~ /F/i) {
        check_file_exists($first_second_intersect);
        open my $FH, '>', $first_second_intersect or die "Could not write to '$first_second_intersect': $!";
        print $FH "$_\n" for sort @$isect_ref;
        close $FH;
    }
    else {
        print "$_\n" for sort @$isect_ref;
    }
}

exit(0);

