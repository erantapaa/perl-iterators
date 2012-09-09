use strict;
use warnings;
use Test::More;
use i::test_utils;
use i;

BEGIN { use_ok('i::re') };

sub t {
  my $sub = shift;
  my %args = @_;
  my $re = delete $args{re};
  my $source = delete $args{source};
  my $expected = delete $args{expected};
  my %rest = @_;
  $rest{level} ++;

  my $s = i::array($source);
  my $i = do { no strict 'refs'; $sub->($re, $s) };

  stream_is( $i, $expected, %rest);
}

t(
 'matches_array',
  re => qr/(\w+)/,
  source => ['this is a', 'test 123'],
  expected => [ map {[$_]} qw/this is a test 123/ ],
);

t('match_once_array',
  re => qr/(\w+)/,
  source => ['this is a', 'test 123'],
  expected => [ map {[$_]} qw/this test/ ]
);

t('matches_named',
  re => qr/(?<w1>\w+)\s+(?<w2>\w+)/,
  source => ['this is a good test', 'of the emergency broadcast system'],
  expected => [ {w1 => 'this', w2 => 'is' },
                {w1 => 'a', w2 => 'good' },
                {w1 => 'of', w2 => 'the' },
                {w1 => 'emergency', w2 => 'broadcast'}
              ],
);

t('match_once_named',
  re => qr/(?<w1>\w+)\s+(?<w2>\w+)/,
  source => ['this is a good test', 'of the emergency broadcast system'],
  expected => [ {w1 => 'this', w2 => 'is' },
                {w1 => 'of', w2 => 'the' },
              ],
);

done_testing();

