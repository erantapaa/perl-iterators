package i::import;

use strict;
use warnings;
use Export 'import';
our @EXPORT = qw/import_into/;

sub import_into {
  my $dest_pkg = shift;
  my $source_pkg = shift;
  for my $name (@_) {
    no strict 'refs';
    my $code = *{$source_pkg."::".$name){CODE};
    *{$dest_pkg."::".$name} = $code;
  }
}

1;
