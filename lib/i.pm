package i;

use strict;
use warnings;
use feature ":5.10";
use d ();
use Carp;
use i::iter;
use Scalar::Util qw/reftype blessed/;

our @submodules = qw/range re directory argv lines json csv dbi/;

sub import {
  my $package = shift;
  for my $module (@_) {
    unless ($module ~~ @submodules) {
      carp "unknown iterator module $module";
    }
    my $package = "i::".$module;
    require $package;
    $package->import;
  }
}

# Composing and Running iterators

sub compose {
  croak "compose requires at least one argument" unless @_;
  my $i = shift;
  while (@_) {
    $i = $i | shift;
  }
  return $i;
}

sub run {
  my $i = compose(@_);
  # assert $i is a sink
  unless ($i->can('run')) {
    my $label  = $i->can('iter_class') ? $i->iter_class : blessed($i);
    croak "cannot call run on type '$label'";
  }
  $i->run;
}

# Sinks

sub collect {
  transsink {
    my $i = shift;
    sink {
      my @a;
      while (defined(my $x = $i->())) {
        push(@a, $x);
      }
      return \@a;
    }
  }
}

sub do (&) {
  my $f = shift;
  transsink {
    my $i = shift;
    sink {
      while (defined(my $x = $i->())) {
        { local $_ = $x; $f->($x) };
      }   
    }
  };
}

sub drain {
  # this is the same as do {}, but just a little more efficient 
  transsink {
    my $i = shift;
    sink {
      while (defined(my $x = $i->())) { }
    }
  }
}

# Transformers

sub trace {
  transformer {
    my $i = shift;
    source {
      my $x = $i->();
      if (defined($x)) {
        print STDERR d::d($x), "\n";
      }
      return $x;
    }
  }
}

sub filter (&) {
  my $f = shift;
  transformer {
    my $i = shift;
    source {
      while (defined(my $x = $i->())) {
        { local $_ = $x; return $x if $f->($x); }
      }
      return;
    }
  }
}

sub map (&) {
  my $f = shift;
  transformer {
    my $i = shift;
    source {
      while (defined(my $x = $i->())) {
        { local $_ = $x;
          my $y = $f->($x);
          return $y if defined($y);
        }
      }
      return;
    }
  }
}

sub tap (&) {
  my $f = shift;
  transformer {
    my $i = shift;
    source {
      while (defined(my $x = $i->())) {
        $f->($_);
        return $_;
      }
    }
  }
}

sub take ($) {
  my $n = shift;
  transformer {
    my $i = shift;
    source {
      return if $n-- <= 0;
      my $x = $i->();
      return $x if defined($x);
      $n = 0;
      return;
    }
  }
}

sub concat {
  transformer {
    my $i = shift;
    my $j;
    source {
      while (my $j //= $i->()) {
        my $x = $j->();
        return $x if defined($x);
      }
    }
  }
}

# Sources

# -- Arrays and Hashes

sub array {
  my $a = shift;
  my $k = 0;
  source {
    return unless ($k <= $#$a);
    return $a->[$k++];
  }
}

sub array_pairs {
  my $a = shift;
  my $k = 0;
  source {
    return unless ($k <= $#$a);
    my $r = [$k, $a->[$k]];
    $k++;
    return $r;
  }
}

sub hash_pairs {
  my $h = shift;
  source {
    while (my ($k,$v) = each %$h) {
      return [$k,$v];
    }
    return;
  }
}

sub list {
  i::array(\@_);
}

# -- ARGV / <>

sub ARGV { array(\@ARGV) }

sub sayd {
  i::do { say d::d($_) }
}

=head1 NAME

i - an iterator library

=head1 DESCRIPTION

This module implements 'pull'-style iterators. For more background information
on iterators, please see the pod documentation in the B<i::intro> module.

=head1 SYNOPSIS

  use i;
  
  $i = $i1 | $i2 | ... | $in;
  $i = i::compose( $i1 => $i2 => ... => $in);

  # Sinks

  i::run($i);
  i::run( $i1 => $i2 => ... $in );

  my $list = i::collect($i);
  my $list = i::take($n)->($i);
  i::do { ... } $i;

  # Transformers

  i::filter { ... } $i;
  i::map { ... } $i;
  i::tap { ... } $i;
  i::concat( @list );

  # Sources

  i::array(\@list);
  i::array_pairs(\@list);
  i::hash_pairs(\%hash);
  i::ARGV()

=cut

1;

