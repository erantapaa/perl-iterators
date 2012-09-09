package i::lines;

use strict;
use warnings;
use feature ":5.10";
use Carp;
use i::iter;
use i::curry;

use Exporter 'import';
our @EXPORT = qw/lines chomped_lines/;

# -- Lines from files

sub lines ($) {
  my $fh = shift;
  iter {
    readline($fh);
  }
}

sub chomped_lines {
  my $fh = shift;
  iter {
    if (defined(my $x = readline($fh))) {
      chomp $x;
      return $x;
    }
    return;
  }
}

sub diamond {
  iter {
    while (<>) { return $_ }
    return;
  }
}

sub chomped_diamond {
  iter {
    while (<>) { chomp; return $_ }
    return;
  }
}

1;
