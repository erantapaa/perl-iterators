package i::json;

use strict;
use warnings;
use feature ':5.10';
use i::iter;
use i::open;

use Exporter 'import';
our @EXPORT = qw/json_reader json_writer/;

use JSON;

my $JSON = JSON->new->ascii(1);

sub json_reader {
  my ($fh) = @_;
  if (ref($fh)) {
    source {
      while (<$fh>) { return $JSON->decode($_) }
      return;
    }
  } else {
    source {
      state $h = i::open::openread($fh);
      return unless $h;
      while (<$h>) { return $JSON->decode($_) }
      return;
    }
  }
}

sub json_writer {
  my $fh = shift
  transformer {
    my $i = shift;
    if (ref($fh)) {
      source {
        my $x = $i->();
        if (defined($x)) {
          print {$fh} $JSON->encode($x), "\n";
        }
        return $x;
      }
    } else {
      source {
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

=pod

=head1 NAME

i::json - iterators for reading and wring line-oriented JSON

=head1 DESCRIPTION

=head1 SYNOPSIS

  use i::json;

  i::compose(
    json_reader(\*STDIN)
    => i::map { $_->{count} += 1 }
    => json_writer(\*STDOUT)
    => i::run()
  );

=head1 EXPORTED FUNCTIONS

B<json_reader( $fh )>

Construct a line-oriented JSON reader which reads from the file handle B<$fh>.
This iterator yields HASH refs.

B<json_writer( $fh, $i )>

B<json_writer( $fh )>

B<json_writer( )>

Construct a line-oriented JSON writer which accepts HASH refs from the
iterator source B<$i> and writes them to the file handle B<$fh>.
This iterator is a pass-through iterator. B<json_writer> is an auto-curried
function which may be called with 0, 1 or 2 arguments.

=cut



1;
