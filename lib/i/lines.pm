package i::lines;

use strict;
use warnings;
use feature ":5.10";
use i::iter;

use Exporter 'import';
our @EXPORT = qw/lines chomped_lines diamond chomped_diamond/;

# -- Lines from files

sub lines {
  my $fh = shift;
  source {
    readline($fh);
  }
}

sub chomped_lines {
  my $fh = shift;
  source {
    while (<$fh>) { chomp; return $_ }
    return;
  }
}

sub diamond {
  source {
    while (<>) { return $_ }
    return;
  }
}

sub chomped_diamond {
  source {
    while (<>) { chomp; return $_ }
    return;
  }
}

=pod

=head1 NAME

i::lines - iterators which return lines from files

=head1 SYNOPSIS

  lines(\*STDIN)
  chomped_lines(\*STDIN)
  diamond()
  chomped_diamond()

=head1 EXPORTED FUNCTIONS

B<lines( $fh )>

Creates an iterator which returns lines from a file handle using B<readline()>.

B<chomped_lines( $fh )>

Same as B<lines()> but the lines are chomped first before being returned.

B<diamond()>

Return lines from the diamond B(E<lt>E<gt>) operator.

B<chomped_diamond()>

Same as B<diamond()> but the lines are chomped first.

=cut

1;
