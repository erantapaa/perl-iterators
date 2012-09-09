package i;

use strict;
use warnings;
use feature ":5.10";
use d ();
use Carp;
use i::curry;
use i::iter;

our @submodules = qw/range re directory argv lines json csv dbi/;

sub import {
  my $package = shift;
  for my $module (@_) {
    unless ($module ~~ @submodules) {
      carp "unknown iterator module $module";
    }
    my $package = "i::".$module;
    require $package;
    $package->import;
  }
}

# Composition

sub compose {
  die "compose requires at least one argument" unless @_;
  my $i = shift;
  for (@_) { $i = $_->($i) }
  return $i;
}

# Sinks

sub run_ : curry1(run) {
  my $i = shift;
  while (defined($i->())) { }
  return;
}

sub trace_ : curry1(trace) {
  my $i = shift;
  iter {
    my $x = $i->();
    if (defined($x)) {
      print STDERR d::d($x), "\n";
    }
    return $x;
  };
}

sub collect_ : curry1(collect) {
  my ($i) = @_;
  my @a;
  while (defined(my $x = $i->())) {
    push(@a, $x);
  }
  return \@a;
}

sub do_ (&$) : curry2code(do) {
  my ($f, $i) = @_;
  while (defined(my $x = $i->())) {
    { local $_ = $x;
      $f->($x);
    };
  }
  return;
}

# Transformers

sub filter_ (&$) : curry2code(filter) {
  my ($f, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      { local $_ = $x;
        return $x if $f->($x);
      }
    }
    return;
  }
}

sub map_ (&$) : curry2code(map) {
  my ($f, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      { local $_ = $x;
        my $y = $f->($x);
        return $y if defined($y);
      }
    }
    return;
  }
}

sub tap_ (&$) : curry2code(tap) {
  my ($f, $i) = @_;
  iter {
    local $_ = $i->();
    if (defined($_)) {
      $f->($_);
    }
    return $_;
  }
}

sub take_ : curry2(take) {
  my ($n, $i) = @_;
  iter {
    return unless $n-- > 0;
    my $x = $i->();
    return $x if defined($x);
    $n = 0;
    return;
  }
}

sub concat_ : curry1(concat) {
  my ($i) = @_;
  my $j;
  iter {
    while (my $j //= $i->()) {
      my $x = $j->();
      return $x if defined($x);
    }
  }
}

# Sources

# -- Arrays and Hashes

sub array {
  my $a = shift;
  my $k = 0;
  iter {
    return unless ($k <= $#$a);
    return $a->[$k++];
  }
}

sub array_pairs {
  my $a = shift;
  my $k = 0;
  iter {
    return unless ($k <= $#$a);
    my $r = [$k, $a->[$k]];
    $k++;
    return $r;
  }
}

sub hash_pairs {
  my $h = shift;
  iter {
    while (my ($k,$v) = each %$h) {
      return [$k,$v];
    }
    return;
  }
}

# -- ARGV / <>

sub ARGV { array(\@ARGV) }

sub sayd_ : curry1(sayd) {
  my $i = shift;
  i::do { say d::d($_) } $i;
}

1;

