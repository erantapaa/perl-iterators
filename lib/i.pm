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

=head1 NAME

i - an iterator library

=head1 DESCRIPTION

This module implements 'pull'-style iterators. An pull-iterator is simply a CODE ref
which will return the next value in a stream of values every time it is called.
When the iterator has no more values to yield it returns B<undef>.

=head1 ITERATOR TYPES

There are three kinds of iterators:

=over 4

=item SOURCES

=item TRANSFORMERS

=item SINKS

=back

SOURCES appear at the beginning of an iterator chain and produce values without requiring
input from another iterator.

TRANSFORMERS take an iterator as input to create a new iterator.
TRANSFORMERS appear in the middle of an iterator chain.

Like TRANSFORMERS, SINKS take an iterator as input, but do not create a new iterator.
SINKS may only appear at the end of an iterator chain.

Examples of each kind of iterator:

  my $source = sub { state $n = 4; $n ? $n-- : undef }

  my $sink = sub { my $i = shift;
                   while (defined(my $x = $i->())) {
                     print $x, " ";
                   }
                   print "\n";
                 }

  my $filter = sub { my $i = shift;
                     sub {
                       while (defined(my $x = $i->())) {
                         next unless $x % 2 == 0;
                         return 10*$x;
                       }
                      }
                    }

The iterator B<$source> will yield the values 4, 3, 2 and 1 before returning B<undef>
which is the signal that the stream has been exhausted.

The transformer B<$filter> reads from an input iterator, filters out those values
which are even and otherwise returns a function (in this case 10*$x) of the input stream value.

The sink B<$sink> reads from an input iterator and prints out each value from that stream.

Strictly speaking TRANSFORMERS and SINKS are not iterators themselves but functions of
iterators. Hopefully this won't be too confusing.

=head1 COMPOSING ITERATORS

SOURCES, TRANSFORMERS and SINKS may be composed together to form new iterators
using the function B<i::compose>.

Examples:

    i::compose( $source => $sink )
      -- prints: 4 3 2 1

    i::compose( $source => $filter => $sink )
      -- prints: 40 20

    i::compose( $source => $filter => $filter => $sink )
      -- prints: 400 200

It's up to the user to make sure that the composition makes sense.
In general a chain of iterators may be composed if each pair of iterators in the chain
is either:

=over 4

=item
a SOURCE feeding into a TRANSFORMER

=item
a SOURCE feeding into a SINK

=item
a TRANSFORMER feeding into another TRANSFORMER

=item
a TRANSFORMER feeding into a SINK

=back

=cut

1;

