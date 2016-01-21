package Text::Abbrev;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(abbrev);

=head1 NAME

Text::Abbrev - create an abbreviation table from a list (e.g. of words)

=head1 SYNOPSIS

    use Text::Abbrev;
    abbrev $hashref, LIST


=head1 DESCRIPTION

This module exports an C<abbrev> function that generates
all unambiguous truncations of each string in a list of strings.
Each truncation is returned as the key of a hash,
with the value being the original string.

For example, if you called the following:

    %hash = abbrev qw(blue blood);

You would get the following entries in C<%hash>:

    blu   => blue
    blue  => blue
    blo   => blood
    bloo  => blood
    blood => blood

Whereas if you called it with the list C<(red blood)>,
you'd get the following:

    r     => red
    re    => red
    red   => red
    b     => blood
    bl    => blood
    blo   => blood
    bloo  => blood
    blood => blood

=head1 EXAMPLE

These illustrate the different ways you can call the C<abbrev> function:

    $hashref = abbrev qw(list edit send abort gripe);

    %hash = abbrev qw(list edit send abort gripe);

    abbrev $hashref, qw(list edit send abort gripe);

    abbrev(*hash, qw(list edit send abort gripe));

=cut


# Usage:
#	abbrev \%foo, LIST;
#	...
#	$long = $foo{$short};

sub abbrev {
    my ($word, $hashref, $glob, %table, $returnvoid);

    @_ or return;   # So we don't autovivify onto @_ and trigger warning
    if (ref($_[0])) {           # hash reference preferably
      $hashref = shift;
      $returnvoid = 1;
    } elsif (ref \$_[0] eq 'GLOB') {  # is actually a glob (deprecated)
      $hashref = \%{shift()};
      $returnvoid = 1;
    }
    %{$hashref} = ();

    WORD: foreach $word (@_) {
        for (my $len = (length $word) - 1; $len > 0; --$len) {
	    my $abbrev = substr($word,0,$len);
	    my $seen = ++$table{$abbrev};
	    if ($seen == 1) {	    # We're the first word so far to have
	    			    # this abbreviation.
	        $hashref->{$abbrev} = $word;
	    } elsif ($seen == 2) {  # We're the second word to have this
	    			    # abbreviation, so we can't use it.
	        delete $hashref->{$abbrev};
	    } else {		    # We're the third word to have this
	    			    # abbreviation, so skip to the next word.
	        next WORD;
	    }
	}
    }
    # Non-abbreviations always get entered, even if they aren't unique
    foreach $word (@_) {
        $hashref->{$word} = $word;
    }
    return if $returnvoid;
    if (wantarray) {
      %{$hashref};
    } else {
      $hashref;
    }
}

1;

=head1 REPOSITORY

C<Text::Abbrev> is a core module -
it has always been shipped with Perl 5.

It is a dual-life module though,
which means it also gets separate CPAN releases. 

The repository for the CPAN releases: L<https://github.com/rafl/text-abbrev>

=head1 LICENSE

This program is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

