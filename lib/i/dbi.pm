packge i::dbi;

use strict;
use warnings;
use i::iter;

use Exporter 'import';
our @EXPORT = qw/sth_arrayref sth_hashref/;

sub sth_arrayref {
  my ($sth) = @_;
  iter {
    $sth->fetchrow_arrayref;
  }
}

sub sth_hashref {
  my ($sth) = @_;
  iter {
    $sth->fetchrow_hashref;
  }
}

1;
