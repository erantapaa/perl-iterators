package d;

use strict;
use warnings;

use Data::Dumper;

use Exporter 'import';
our @EXPORT = ('d');
our @EXPORT_OK = ('lazyd');

sub d {
  local $Data::Dumper::Terse = 1;
  local $Data::Dumper::Indent = 0;
  my $x = Dumper(\@_);
  substr($x, 1, length($x)-2);
}

sub lazyd {
  bless \@_, "d::lazy";
}

package d::lazy;

use strict;
use warnings;

use overload '""' => \&stringify;

sub stringify {
  my $x = shift;
  return d::d(@$x);
}

1;
