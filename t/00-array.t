use strict;
use warnings;
use Test::More;
use i::test_utils;

BEGIN { use_ok('i') };

stream_is( i::array([]), [] );
stream_is( i::array([6,4,5,3,4]), [6,4,5,3,4]);

done_testing();

