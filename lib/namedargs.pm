package namedargs;

use strict;
use warnings;
use Carp;

sub new {
  my ($class, $params) = @_;
  my %args = @$params;
  my %present = map { ($_,1) } keys %args;
  bless { args => \%args, present => \%present }, $class;
}

sub getarg {
  my $self = shift;
  my $name = shift;
  my $optional = shift;
  my $optvalue = shift;

  my $found = exists $self->{args}->{$name};

  delete $self->{present}->{$name};

  if ($found) {
    my $value = $self->{args}->{$name};
    for my $check (@_) {
      $check->($value, $name, $self);
    }
    return $value;
  } elsif ($optional) {
    return $optvalue;
  } else {
    local $Carp::CarpLevel = 2;
    croak "required parameter '$name' not found";
  }
}

sub optional {
  my $self = shift;
  my $name = shift;
  $self->getarg($name, 1, @_);
}

sub required {
  my $self = shift;
  my $name = shift;
  $self->getarg($name, 0, undef, @_);
}

sub noleftovers {
  my ($self) = @_;
  if (%{$self->{present}}) {
    local $Carp::CarpLevel = 1;
    croak "unrecognized parameter(s): ".join(', ', keys %{$self->{present}});
  }
}

=pod

=head1 NAME

namedargs - library for processing named argments

=head1 SYNOPSIS

  use namedargs;
  use namedargs::checks qw/check_defined/;

  sub foo {
    # e.g. foo(req1 => ..., req2 => ..., [opt1 => ...])
    my $args = namedargs->new(\@_);
    my $req1 = $args->required("req1");
    my $opt1 = $args->optional("opt1", "default-value");

    my $req2 = $args->required("req2", \&check_defined);

    $args->noleftovers;

    # ...
  }

  foo()                  # required parameter 'req1' not found
  foo(req1 => 3)         # required parameter 'req2' not found
  foo(req1 => 3, req2 => undef)
                         # parameter 'req2' cannot be undef
  foo(req1 => 3, req2 => 4, other => 5)
                         # unrecognized parameter(s): other

=head1 METHODS

B<new( $ARGS )>

Create a new B<namedargs> object with the argument array B<$ARGS>.

B<required($name, @checks )>

Lookup the value of the named argument B<$name> and throw
an exception if the argument is not present. Otherwise
return its value after performing the specified checks.

B<optional($name, $default, @checks)>

Lookup the value of the named argument B<$name>.
If the argument is not present, return B<$default>.
Otherwise perform the specified checks before returning the value of the argument.

B<noleftovers>

Throw an exception if there were named arguments which were not retrieved
using either B<required> or B<optional>.

=head1 CHECK FUNCTIONS

The B<requried> and B<optional> methods can take a list of B<check functions>.
These are functions which are allowed to inspect (and possibly modify) the
returned argument value before it is returned to the caller.

The module B<namedargs::checks> contain some commonly used check functions.

=cut

1;

