package i::curry;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT = qw/MODIFY_CODE_ATTRIBUTES/;

sub MODIFY_CODE_ATTRIBUTES {
  my ($class, $code, @attrs) = @_;

  my (@bad, @curries);

  for (@attrs) {
    if (m,\A(curry1|curry2|curry2code)\((\w+)\)\z,) {
      push(@curries, [ $1, $2, $_ ]);
    } else {
      push(@bad, $_);
    }
  }
  if (@bad) {
    return @bad;
  }
  if (@curries > 1) {
    return map { $_->[2] } @curries;
  }
  if (@curries) {
    my $type = $curries[0]->[0];
    my $name = $curries[0]->[1];
    if ($type eq "curry1") {
      curry1($code, $name, $class);
    } elsif ($type eq "curry2") {
      curry2($code, $name, $class);
    } elsif ($type eq "curry2code") {
      curry2code($code, $name, $class);
    } else {
      die "huh - how did I get here???, type = $type";
    }
  }
  return;
}

sub curry1 {
  my ($code, $name, $class) = @_;

  my $fullname = "$class\::$name";
  no strict 'refs';
  *{$fullname} = sub {
    if (@_ == 0) { sub { goto &$code } }
    elsif (@_ == 1) { goto &$code }
    else {
      die "$fullname: expecting 0 or 1 arguments, found ".scalar(@_);
    }
  };
}

sub curry2code {
  my ($code, $name, $class) = @_;

  my $fullname = "$class\::$name";
  no strict 'refs';
  *{$fullname} = sub (&@) {
    if (@_ == 2) { goto &$code }
    elsif (@_ == 1) {
      my $arg = shift;
      sub {
        unshift(@_, $arg);
        goto &$code;
      }
    } else {
      die "$fullname: expecting 1 or 2 arguments, found ".scalar(@_);
    }
  };
}

sub curry2 {
  my ($code, $name, $class) = @_;

  my $fullname = "$class\::$name";
  no strict 'refs';
  *{$fullname} = sub {
    if (@_ == 2) { goto &$code }
    elsif (@_ == 1) {
      my $arg = shift;
      sub {
        unshift(@_, $arg);
        goto &$code;
      }
    } else {
      die "$fullname: expecting 1 or 2 arguments, found ".scalar(@_);
    }
  };
}

1;

