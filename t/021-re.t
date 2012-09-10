use strict;
use warnings;
use Test::More;
use i::test_utils;
use i;

BEGIN { use_ok('i::re') };

my $t1 = c2(code   => 'matches_array',
            arg    => qr/(\w+)/,
            source => ['this is a', 'test 123'],
            expect => [ map {[$_]} qw/this is a test 123/ ],
           );

test_c2($t1);

my $t2 =
  c2(code   => 'match_once_array',
     arg    => qr/(\w+)/,
     source => ['this is a', 'test 123'],
     expect => [ map {[$_]} qw/this test/ ]
         );

my $t3 =
  c2( code   => 'matches_named',
      arg    => qr/(?<w1>\w+)\s+(?<w2>\w+)/,
      source => ['this is a good test', 'of the emergency broadcast system'],
      expect => [ {w1 => 'this', w2 => 'is' },
                    {w1 => 'a', w2 => 'good' },
                    {w1 => 'of', w2 => 'the' },
                    {w1 => 'emergency', w2 => 'broadcast'}
                  ],
  );

my $t4 =
  c2(code   => 'match_once_named',
     arg    => qr/(?<w1>\w+)\s+(?<w2>\w+)/,
     source => ['this is a good test', 'of the emergency broadcast system'],
     expect => [ {w1 => 'this', w2 => 'is' },
                 {w1 => 'of', w2 => 'the' },
              ],
  );

done_testing();

