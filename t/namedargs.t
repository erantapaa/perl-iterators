use strict;
use warnings;
use Test::More;
use Test::Exception;
use namedargs;

sub foo {
  my $a = namedargs->new(\@_);
  my $x1 = $a->required('x1');

  $a->noleftovers;

  return "x1: $x1";
}

throws_ok { foo() } qr/required parameter 'x1' not found/;
lives_ok { foo(x1 => 3) };

is(foo(x1 => 3), "x1: 3");

throws_ok { foo(x1 => 4, y1 => 5) } qr/unrecognized parameter.s.: y1/;

done_testing();

