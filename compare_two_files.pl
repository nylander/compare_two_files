#!/usr/bin/perl

#===============================================================================
#
#         FILE:  compare_two_files.pl
#
#        USAGE:  ./compare_two_files.pl [options] file1 file2
#
#  DESCRIPTION:  Compares two lists in two separate files.
#                Use perldoc compare_two_files.pl, or
#                ./compare_two_files.pl --man for more info.
#
#      CREATED:  02/11/2008 10:27:45 AM CEST
#     REVISION:  10/10/2011 10:53:58 AM
#
#===============================================================================

use strict;
use warnings;
use File::Slurp;
use List::Compare;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;


## Globals
my $silent               = 0; # default is interactive
my @union                = ();
my @isect                = ();
my @diff                 = ();
my @first_only           = ();
my @second_only          = ();
my @first_or_second_only = ();
my @first_list           = ();
my @second_list          = ();
my @bag                  = ();
my @LorRonly             = ();
my ($union_size, $isect_size, $first_only_size, $second_only_size, $bag_size);
my ($LorRonly_size, $first_list_size, $second_list_size);
my ($first_file_unique, $second_file_unique, $first_and_second_intersection_file);
my ($lc, $query, $res, $first_file, $second_file, $eqv, $disj);
my ($unique1, $unique2, $union, $intersection);


#===  FUNCTION  ================================================================
#         NAME:  promptUser
#      VERSION:  03/31/2009 11:12:39 AM CEST
#  DESCRIPTION:  taken from
#                http://www.devdaily.com/perl/edu/articles/pl010005/pl010005.shtml
#                (with minor modifications)
#   PARAMETERS:  Usage (e.g.): my $query = promptUser("Print?", "Y");
#===============================================================================
sub promptUser {

    my ($promptString, $defaultValue) = @_;

    if ($defaultValue) {
        print $promptString, "[", $defaultValue, "]: ";
    }
    else {
        print $promptString, ": ";
    }

    $| = 1; # force a flush after our print
    $_ = <STDIN>;

    chomp;

    if ("$defaultValue") {
        return $_ ? $_ : $defaultValue; # return $_ if it has a value
    }
    else {
        return $_;
    }

} # end of promptUser()


## Get arguments and files
GetOptions('silent'       => \$silent,
           'union'        => \$union,
           'intersection' => \$intersection,
           '1|one'          => \$unique1,
           '2|two'          => \$unique2,
           'help'         => sub { pod2usage(1); },
           'man'          => sub { pod2usage(-exitstatus => 0, -verbose => 2); });

die "Input error. Try $0 --help for more info\n" unless (@ARGV == 2);

$first_file  = shift(@ARGV);
$second_file = shift(@ARGV);
@first_list  = read_file($first_file);
@second_list = read_file($second_file);


## Compare files
$lc          = List::Compare->new(\@first_list, \@second_list);
@isect       = $lc->get_intersection;
@union       = $lc->get_union;
@first_only  = $lc->get_Lonly;
@second_only = $lc->get_Ronly;
@bag         = $lc->get_bag;
$eqv         = $lc->is_LequivalentR;
$disj        = $lc->is_LdisjointR;
@LorRonly    = $lc->get_symmetric_difference;

## Get sizes
$first_list_size  = @first_list;
$second_list_size = @second_list;
$union_size       = @union;
$isect_size       = @isect;
$first_only_size  = @first_only;
$second_only_size = @second_only;
$bag_size         = @bag;
$LorRonly_size    = @LorRonly;

## Print results
if ($disj) { # if lists are either too similar/dissimilar: go no further 
    die "the lists in the two files have zero elements in common\n";
}
if (($LorRonly_size == 0) && ($first_list_size == $second_list_size)) {
    die "the lists in the two files have the same items\n"
}
## Output to STDERR
if ($union) {
    foreach (@union) {
        print STDOUT;
    }
    exit(0); 
}
elsif ($intersection) {
    foreach (@isect) {
        print STDOUT;
    }
    exit(0); 
}
elsif ($unique1) {
    foreach (@first_only) {
        print STDOUT;
    }
    exit(0);
}
elsif ($unique2) {
    foreach (@second_only) {
        print STDOUT;
    }
    exit(0);
}
## Output to screen or files
$first_file_unique = $first_file . ".unique";
$second_file_unique = $second_file . ".unique";
$first_and_second_intersection_file = $first_file . "." . $second_file . ".intersection";

if ($silent) {
    write_file($first_file_unique, @first_only);
    write_file($second_file_unique, @second_only);
    write_file($first_and_second_intersection_file, @isect);
}
else {
    print STDERR"\nComparing \'$first_file\' with \'$second_file\':\n\n";
    print STDERR " total number of items: $bag_size\n";
    print STDERR " total number of unique items (union): $union_size\n";
    print STDERR " found in \'$first_file\' only: $first_only_size\n";
    print STDERR " found in \'$second_file\' only: $second_only_size\n";
    print STDERR " found in both (intersection): $isect_size\n";
    print STDERR "\n";

    ## First file
    $query = promptUser("\nUnique values in \'$first_file\':\n Write to file \'$first_file_unique\' (F) or to screen (S)? ", "S");
    if ($query =~ /F/i) {
        write_file($first_file_unique, @first_only);
    }
    else {
        foreach (@first_only) {
            print STDOUT;
        }
    }
    ## Second file
    $query = promptUser("\nUnique values in \'$second_file\':\n Write to file \'$second_file_unique\' (F) or to screen (S)? ", "S");
    if ($query =~ /F/i) {
        write_file($second_file_unique, @second_only);
    }
    else {
        foreach (@second_only) {
            print STDOUT;
        }
    }
    ## Both files
    $query = promptUser("\nShared values (intersection) in \'$first_file\' and \'$second_file\':\n Write to file (\'$first_and_second_intersection_file\') (F) or to screen (S)? ", "S");
    if ($query =~ /F/i) {
        write_file($first_and_second_intersection_file, @isect);
    }
    else {
        foreach (@isect) {
            print STDOUT;
        }
    }

}

exit(0);

#===  POD DOCUMENTATION  =======================================================
#      VERSION:  10/10/2011 10:53:41 AM
#  DESCRIPTION:  Documentation
#         TODO:  ?
#===============================================================================
=pod

=head1 NAME

compare_two_files.pl


=head1 VERSION

Documentation for compare_two_files.pl version 1.0


=head1 SYNOPSIS

compare_two_files.pl [--union|--intersection|--one|--two|--silent] [--help] [--man]  FILE1 FILE2


=head1 DESCRIPTION

Compares two lists in two separate files.

Shows the results interactively, or, if the B<--silent> option
is used, silently.

Unique values in the first and second files can be extracted
using  the B<-1, --one>, or B<-2, --two> options, respectively, as well
as the intersection (B<--intersection>), and union (B<--union>).


=head1 OPTIONS

Mandatory arguments to long options are mandatory for short options too


=over 8

=item B<-u, --union>

Get those items which appear at least once in either B<FILE1> and B<FILE2> (their I<union>).


=item B<-i, --intersection>

Get those items which appear at least once in both B<FILE1> and B<FILE2> (their I<intersection>).


=item B<-1, -o, --one>

Print the I<unique> values in list from B<FILE1>.


=item B<-2, -t, --two>

Print the I<unique> values in list from B<FILE2>.


=item B<-h, --help>

Prints I<help> message and exits.


=item B<-m, --man>

Displays the I<manual> page.


=item B<FILEN>

B<FILE>, and B<FILE2> should contain lists to be compared (one in each file).


=back


=head1 USAGE

Examples:

  compare_two_files.pl FILE1 FILE2
  compare_two_files.pl --silent FILE1 FILE2
  compare_two_files.pl --union FILE1 FILE2
  compare_two_files.pl --intersection FILE1 FILE2
  compare_two_files.pl -1 FILE1 FILE2
  compare_two_files.pl -2 FILE1 FILE2


=head1 AUTHOR

Written by Johan A. A. Nylander


=head1 REPORTING BUGS

Please report any bugs to I<jnylander @ users.sourceforge.net>.


=head1 DEPENDENCIES

Perl modules from CRAN: File::Slurp, List::Compare.


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Johan Nylander. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details. 
http://www.gnu.org/copyleft/gpl.html 


=cut

