package i::test_utils;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw/stream_is initial_stream_is/;

# Define our own basic collect function.

sub _collect {
  my ($i) = @_;
  my @list;
  while (defined(my $x = $i->())) { push(@list, $x) }
  return \@list;
}

sub _take {
  my ($n, $i) = @_;
  my @list;
  while ($n-- > 0 && defined(my $x = $i->())) {
    push(@list, $x);
  }
  return \@list;
}

sub at {
  my ($depth) = @_;
  my @c = caller($depth);
  ("at ".$c[1]." line ".$c[2]);
}

sub stream_is {
  my $i = shift;
  my $expected = shift;
  my %args = @_;
  my $name = delete $args{name};
  my $initial = delete $args{initial};
  my $level = delete $args{level} || 0;

  $name = at(1+$level) unless defined($name);

  my $n = scalar(@$expected);
  unless ($initial) {
    $n++;
  }
  Test::More::is_deeply( _take($n, $i), $expected, $name);
}

1;

