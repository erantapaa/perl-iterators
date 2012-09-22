package i::iter;

use strict;
use warnings;
use Carp;
use constant { SOURCE => 1, SINK => 2, TRANSFORMER => 3, TRANSSINK => 4 };

use Exporter 'import';
our @EXPORT = qw/source sink transformer transsink/;

sub source (&) {
  bless $_[0], 'i::iter::source';
}

sub transformer (&) {
  bless $_[0], 'i::iter::transformer';
}

sub transsink (&) {
  bless $_[0], 'i::iter::transsink';
}

sub sink (&) {
  bless $_[0], 'i::iter::sink';
}

sub pipe {
  my ($i, $j) = @_;
  unless ($i->can('iter_type') && $j->can('iter_type')) {
    croak("operand to pipe is not an iterator");
  }
  my $i_type = $i->iter_type;
  my $j_type = $j->iter_type;
  if ($i_type == SOURCE) {  # source
    if ($j_type == SOURCE) {
       croak "cannot connect a source to a source";
     } elsif ($j_type == TRANSFORMER) {
       my $r = $j->($i); # should be a source
       unless ($r->iter_type == SOURCE) {
         croak "result of source | transformer did not return a source: ".$r->iter_type;
       }
       return $r;
     } elsif ($j_type == TRANSSINK) {
       return $j->($i);
     } elsif ($j_type == SINK) {
       return $j->($i);
     }
  } elsif ($i_type == TRANSFORMER) { # i is a transformer 
    if ($j_type == SOURCE) {
      croak "cannot pipe from a transformer to a source";
    } elsif ($j_type == TRANSFORMER) {
      return transformer { $j->($i->($_[0])) }
    } elsif ($j_type == SINK) {
      return transsink { $j->($i->($_[0])) };
    } elsif ($j_type == TRANSSINK) {
      return transsink { $j->($i->($_[0])) };
    }
  } elsif ($i_type == SINK) {
    croak "cannot pipe from a sink";
  } elsif ($i_type == TRANSSINK) {
    croak "cannot pipe from a trans-sink";
  } else {
    croak "should not get here - i_type = $i_type";
  }
  croak "should not be here";
}

package i::iter::source;

use overload "|" => \&i::iter::pipe;

sub iter_type { i::iter::SOURCE }

package i::iter::sink;

use overload "|" => \&i::iter::pipe;

sub iter_type { i::iter::SINK }

sub run {
  $_[0]->();
}

package i::iter::transformer;

use overload "|" => \&i::iter::pipe;

sub iter_type { i::iter::TRANSFORMER }

package i::iter::transsink;

use overload "|" => \&i::iter::pipe;

sub iter_type { i::iter::TRANSSINK}

1;

