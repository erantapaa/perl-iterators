
package i::test::c2;

sub new {
  my ($class, $code, $arg, $source, $expected) = @_;
  bless { code => $code, arg => $arg, source => $source, expected => $expected }, $class;
}

sub code { $_[0]->{code} }
sub arg { $_[0]->{arg} }
sub source { $_[0]->{source} }
sub expected { $_[0]->{expected} }

1;

