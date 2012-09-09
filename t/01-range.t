use strict;
use warnings;
use Test::More;
use i::test_utils;

BEGIN { use_ok('i::range') };

# upto

stream_is( upto(10,10), [10] );
stream_is( upto(1,0),   []   );
stream_is( upto(9,8,1), []   );
stream_is( upto(3,10,2), [3,5,7,9]);

stream_is( upto(7),          [7,8,9,10,11], initial => 1 );
stream_is( upto(-3,undef,4), [-3, 1, 5, 9, 13], initial => 1 );

# downto

stream_is( downto(6,6), [6] );
stream_is( downto(8,9), [] );
stream_is( downto(0, -4, 1), [0,-1,-2,-3,-4] );
stream_is( downto(100, 90.5, 3), [100, 97, 94, 91]);

stream_is( downto(450),        [450, 449, 448, 447, 446], initial => 1 );
stream_is( downto(-6,undef,4), [-6, -10, -14, -18, -22], initial => 1);

# fromto

stream_is( fromto(5, 10), [5,6,7,8,9,10] );
stream_is( fromto(10, 5), [10,9,8,7,6,5] );

stream_is( fromto(8),          [8,9,10,11,12,13,14,15,16,17], initial => 1);
stream_is( fromto(-5,undef,2), [-5,-3,-1,1], initial => 1);

stream_is( fromto(10,5,2), [10,8,6] );

done_testing();

