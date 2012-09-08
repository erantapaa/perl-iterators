package i::re;

use strict;
use warnings;
use feature ":5.10";
use d ();
use Carp;
use i::curry;
use i::iter;

sub matches_named_ : curry1(matches_named) {
  my ($re, $i) = @_;
  my $line;
  iter {
    while () {
      unless (defined($line)) {
        $line = $i->();
        return unless defined($line);
      }
      while ($line =~ m/$re/g) {
        return { %+ };
      }
      $line = undef;
    }
  }
}

sub matches_array_ : curry2(matches_array) {
  my ($re, $i) = @_;
  my $line;
  iter {
    while () {
      unless (defined($line)) {
        $line = $i->();
        return unless defined($line);
      }
      if ($line =~ m/$re/g) {
        return [ map { substr($line, $-[$_], $+[$_] - $-[$_]) } (1..$#-) ];
      }
      $line = undef;
    }
  }
}

sub match_once_named_ : curry2(match_once_named) {
  my ($re, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      if ($x =~ m/$re/) {
        return { %+ };
      }
    }
    return;
  }
}

sub match_once_array_ : curry2(match_once_array) {
  my ($re, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      next unless $x =~ m/$re/;
      return [ map { substr($x, $-[$_], $+[$_] - $-[$_]) } (1..$#-) ];
    }
    return;
  }
}

1;

