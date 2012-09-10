
package i::test::c2;

sub new {
  my ($class, $code, $arg, $source, $expect) = @_;
  bless { code => $code, arg => $arg, source => $source, expect => $expect }, $class;
}

sub code { $_[0]->{code} }
sub arg { $_[0]->{arg} }
sub source { $_[0]->{source} }
sub expect { $_[0]->{expect} }

1;

