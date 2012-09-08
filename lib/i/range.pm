package i::range;

use strict;
use warnings;
use feature ":5.10";
use d ();
use Carp;
use i::iter;

sub upto {
  unless (@_ == 1 || @_ == 2 || @_ == 3) {
    croak "upto: unexpected number of arguments (".scalar(@_).")";
  }
  my ($x, $y, $step) = @_;
  if (defined($step) && $step < 0) {
    carp "upto: step is < 0: $step";
  }
  $step //= 1;
  # $step is defined
  unless (defined($y)) {
    return _range_unbounded($x, $step);
  }
  # $x and $y are defined
  return _range_pos($x, $y, $step);
}

sub downto {
  unless (@_ == 1 || @_ == 2 || @_ == 3) {
    croak "downto: unexpected number of arguments (".scalar(@_).")";
  }
  my ($x, $y, $step) = @_;
  if (defined($step) && $step < 0) {
    carp "downto: step is < 0: $step";
  }
  $step //= 1;
  # $step is defined
  unless (defined($y)) {
    return _range_unbounded($x, -$step);
  }
  # $x and $y are defined
  return _range_neg($x, $y, -$step);
}

sub fromto {
  unless (@_ == 1 || @_ == 2 || @_ == 3) {
    croak "fromto: unexpected number of arguments (".scalar(@_).")";
  }
  my ($x, $y, $step) = @_;
  if (defined($step) && $step < 0) {
    carp "fromto: step is < 0: $step";
  }
  $step //= 1;
  # $step is defined
  unless (defined($y)) {
    return _range_unbounded($x, $step);
  }
  # $x and $y are defined
  if ($x <= $y) {
    return _range_pos($x, $y, $step);
  } else {
    return _range_neg($x, $y, -$step);
  }
}

sub range {
  # range($n) => _range_unbounded($n,1)
  # range($n, $m) => _range_{pos/neg}($n, $m, +/-1)
  # range($n, $m, $step) => _range_{pos/neg}($n, $m, $step)
  if (@_ == 1) {
    return _range_unbounded($_[0], 1);
  } elsif (@_ == 2 || @_ == 3) {
    my ($x, $y, $z) = @_;
    unless (defined($z)) {
      $z = defined($y) ? ($y >= $x ? 1 : -1)
                       : 1;
    }
    # $x and $z are defined
    if (defined($y)) {
      if ($z >= 0) {
        return _range_pos($x, $y, $z);
      } else {
        return _range_neg($x, $y, $z);
      }
    } else {
      return _range_unbounded($x, $z);
    }
  } else {
    die "too many arguments to range: ".d(\@_);
  }
}

sub _range_pos {
  my ($from, $to, $step) = @_;
  iter {
    return if $from > $to;
    my $r = $from;
    $from += $step;
    return $r;
  }
}

sub _range_neg {
  my ($from, $to, $step) = @_;
  iter {
    return if $from < $to;
    my $r = $from;
    $from += $step;
    return $r;
  }
}

sub _range_unbounded {
  my ($from, $step) = @_;
  iter {
    my $r = $from;
    $from += $step;
    return $r;
  }
}

BEGIN {
  no strict 'refs';
  *{"i::upto"} = \&upto;
  *{"i::downto"} = \&downto;
  *{"i::fromto"} = \&fromto;
}

1;

