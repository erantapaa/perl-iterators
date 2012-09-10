package i::test_utils;

use strict;
use warnings;
use Carp;
use i::test::c2;
use namedargs;
use namedargs::checks qw/check_array check_code_or_name/;

use Exporter 'import';
our @EXPORT = qw/stream_is initial_stream_is c2 test_c2/;

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

sub test_c2 {
  my $c2 = shift;
  my %args = @_;
  my $level = delete $args{level} || 0;

  my $name = at(1+$level);
  my $source = $c2->source;
  my $arg = $c2->arg;
  my $code = $c2->code;
  my $expected = $c2->expected;

  {
    my $s = i::array($source);
    my $i = $code->($arg);
    stream_is( $i->($s), $expected, level => $level+1,  name => "$name (curried)");
  }

  {
    my $s = i::array($source);
    my $i = $code->($arg, $s);
    stream_is( $i, $expected, level => $level+1,  name => "$name (non-curried)");
  }

  {
    my $s = i::array($source);
    my $i = i::compose($s, $code->($arg));
    stream_is( $i, $expected, level => $level+1, name => "$name (compose)");
  }
}

sub c2 {
  my $args     = namedargs->new(\@_);
  my $code     = $args->required('code', \&check_code_or_name);
  my $arg      = $args->required('arg');
  my $source   = $args->required('source', \&check_array);
  my $expected = $args->required('expected', \&check_array);
  my $name     = $args->optional('name');
  my $level    = $args->optional('level', 1);

  $args->noleftovers;

  # transform $code into a CODE ref

  if (ref($code) eq "") {
    my @c = caller;
    my $ref = do { no strict 'refs'; *{"$c[0]\::$code"}{CODE} };
    unless ($ref) {
      croak "no sub named $code in package $c[0]";
    }
    $code = $ref;
  } elsif (ref($code) ne "CODE") {
    croak "c2: first argument is not a CODE ref";
  }

  i::test::c2->new($code, $arg, $source, $expected);
}

1;

