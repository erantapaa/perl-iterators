package i::json;

use strict;
use warnings;
use feature ':5.10';
use i::curry;
use i::open;

use Exporter 'import';
our @EXPORT = qw/json_reader json_writer/;

use JSON;

my $JSON = JSON->new->ascii(1);

sub json_reader {
  my ($fh) = @_;
  if (ref($fh)) {
    sub {
      while (<$fh>) { return $JSON->decode($_) }
      return;
    }
  } else {
    sub {
      state $h = i::open::openread($fh);
      return unless $h;
      while (<$h>) { return $JSON->decode($_) }
      return;
    }
  }
}

sub json_writer_ :curry2(json_writer) {
  my ($fh, $i) = @_;
  if (ref($fh)) {
    sub {
      my $x = $i->();
      if (defined($x)) {
        print {$fh} $JSON->encode($x), "\n";
      }
      return $x;
    }
  } else {
    sub {
      state $h = i::openwrite($fh);
      return unless $h;
      my $x = $h->();
      if (defined($x)) {
        print {$fh} $JSON->encode($x), "\n";
      }
      return $x;
    }
  }
}

1;
