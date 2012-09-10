package namedargs::checks;

use strict;
use warnings;
use Carp;
use Exporter 'import';
our @EXPORT = qw/
  check_defined
  check_array
  check_hash
  check_code
  check_code_or_name
/;

sub check_defined {
  my ($v, $n) = @_;
  unless (defined($v)) {
    croak "parameter '$n' cannot be undef";
  }
}

sub check_array {
  my ($v, $n) = @_;
  unless (ref($v) eq "ARRAY") {
    croak "parameter '$n' is not an ARRAY";
  }
}

sub check_hash {
  my ($v, $n) = @_;
  unless (ref($v) eq "HASH") {
    croak "parameter '$n' is not a HASH";
  }
}

sub check_code {
  my ($v, $n) = @_;
  return if ref($v) eq "CODE";
  croak "parameter '$n' is not a CODE ref";
}

sub check_code_or_name {
  my ($v, $n) = @_;
  return if ref($v) eq "CODE";
  unless (ref($v) eq "") {
    croak "parameter '$n' is not a CODE ref";
  }
  unless ($v =~ m/\A[\w:]+\z/) {
    croak "parameter '$n' is not a valid subroutine name";
  }
}

1;
