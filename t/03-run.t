use strict;
use warnings;
use Test::More;
use i::test_utils;

BEGIN { use_ok('i') };

is_deeply( i::run( i::array([4,7,6]) => i::collect() ), [4,7,6] );

my $i1 = i::compose(
           i::array([1,2,3,4,5,6,7,8])
           => i::filter { $_ % 2 == 1 }
           => i::collect()
         );

is_deeply( i::run( $i1 ), [1,3,5,7], at() );

my $s2 = i::array([10,11,12]);
my $i2 = i::map { $_ * 2 } i::array([10,11,12]);

stream_is( $i2, [20,22,24] );

my $i3 = i::compose(
           i::array([10,11,12,13,14,15]) 
           => i::map { $_ % 2 == 0 ? $_/2 : (3*$_+1)/2 }
           => i::collect()
         );

is_deeply( i::run( $i3 ), [5, 17, 6, 20, 7, 23], at() );

my $x4 = i::run( i::array([10..20]) => i::take(4) => i::collect() );

is_deeply( $x4, [10,11,12,13], at() );

my $x5 = i::run( i::array([10..20])  => i::take(0) => i::collect() );

is_deeply( $x5, [], at() );

my $h6 = { a => 3, b => 23, c => 13 };
my $x6 = i::run( i::hash_pairs($h6) => i::collect() );
my $s6 = [ sort { $a->[0] cmp $b->[0] } @$x6 ];

is_deeply( $s6, [ [a => 3], [b => 23], [c => 13] ], at() );

done_testing();

