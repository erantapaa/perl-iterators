
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('i::range') };

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

sub test_range {
  my ($i, $expected, @rest) = @_;
  @rest = at(1) unless @rest;
  is_deeply( _collect($i), $expected, @rest);
}

sub test_take {
  my ($n, $i, $expected, @rest) = @_;
  @rest = at(1) unless @rest;
  is_deeply( _take($n, $i), $expected, @rest);
}

# upto

test_range( i::upto(10,10), [10] );
test_range( i::upto(1,0),   []   );
test_range( i::upto(9,8,1), []   );
test_range( i::upto(3,10,2), [3,5,7,9]);

test_take( 5, i::upto(7),  [7,8,9,10,11] );
test_take( 5, i::upto(-3,undef,4), [-3, 1, 5, 9, 13] );

# downto

test_range( i::downto(6,6), [6] );
test_range( i::downto(8,9), [] );
test_range( i::downto(0, -4, 1), [0,-1,-2,-3,-4] );
test_range( i::downto(100, 90.5, 3), [100, 97, 94, 91]);

test_take( 5, i::downto(450), [450, 449, 448, 447, 446] );
test_take( 5, i::downto(-6,undef,4), [-6, -10, -14, -18, -22]);

# fromto

test_range( i::fromto(5, 10), [5,6,7,8,9,10] );
test_range( i::fromto(10, 5), [10,9,8,7,6,5] );
test_take( 10, i::fromto(8),  [8,9,10,11,12,13,14,15,16,17]);
test_take( 4, i::fromto(-5,undef,2), [-5,-3,-1,1]);
test_range( i::fromto(10,5,2), [10,8,6] );

done_testing();


