package i::csv;

use strict;
use warnings;
use i::iter;
use i::open;

use Exporter 'import';
our @EXPORT = qw/csv_reader csv_writer/;

use Text::CSV;

sub csv_reader {
  my ($fh) = @_;
  if (ref($fh)) {
    return _reader($fh);
  } else {
    source {
      state $h = i::open::openread($fh);
      return unless $h;
      state $i = _reader($h);
      goto &$i;
    }
  }
}

sub _reader {
  my ($fh) = @_;
  my $csv = Text::CSV->new( { binary => 1 } );
  source {
    state $fields = $csv->getline($fh);
    return unless $fields;
    return if $csv->eof;
    my $row = $csv->getline($fh);
    if ($csv->error_diag) {
      die "bad csv line";
    }
    unless ($row) {
      $fields = undef; # stop iteration
      return;
    }
    my %h;
    @h{ @$fields } = @$row;
    return \%h;
  }
}

sub csv_writer_ :curry2(csv_writer) {
  my $fh = shift;
  transformer {
    my $i = shift;
    my $csv = Text::CSV->new({ binary => 1 });
    source {
      my $r = $i->();
      if (defined($r)) {
        $csv->print($fh, $r);
      }
      return $r;
    }
  }
}

1;

