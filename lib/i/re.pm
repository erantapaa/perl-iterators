package i::re;

use strict;
use warnings;
use feature ":5.10";
use d ();
use Carp;
use i::iter;

use Exporter 'import';
our @EXPORT = qw/
  matches_named
  matches_array
  match_once_named
  match_once_array
/;

sub matches_named {
  my $re = shift;
  transformer {
    my $i = shift;
    my $line;
    source {
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
}

sub matches_array {
  my $re = shift;
  transformer {
    my $i = shift;
    my $line;
    source {
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
}

sub match_once_named {
  my $re = shift;
  transformer {
    my $i = shift;
    source {
      while (defined(my $x = $i->())) {
        if ($x =~ m/$re/) {
          return { %+ };
        }
      }
      return;
    }
  }
}

sub match_once_array {
  my $re = shift;
  transformer {
    my $i = shift;
    source {
      while (defined(my $x = $i->())) {
        next unless $x =~ m/$re/;
        return [ map { substr($x, $-[$_], $+[$_] - $-[$_]) } (1..$#-) ];
      }
      return;
    }
  }
}

1;
