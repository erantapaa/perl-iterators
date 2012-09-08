package i::iter;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw/iter/;

sub iter (&) {
  bless $_[0], 'i::iter';
}

1;
