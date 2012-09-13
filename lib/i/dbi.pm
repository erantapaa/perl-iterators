packge i::dbi;

use strict;
use warnings;
use i::iter;

use Exporter 'import';
our @EXPORT = qw/sth_arrayref sth_hashref/;

sub sth_arrayref {
  my ($sth) = @_;
  iter {
    $sth->fetchrow_arrayref;
  }
}

sub sth_hashref {
  my ($sth) = @_;
  iter {
    $sth->fetchrow_hashref;
  }
}

=pod

=head1 NAME

i::dbi - iterate over DBI query results

=head1 SYNSOPSIS

  use i::dbi;

  my $sth = $dbi->prepare("SELECT ...");
  $sth->executed;

  sth_arrayref($sth)    # return next $sth->fetchrow_arrayref 
  sth_hashref($sth)     # return next $sth->fetchrow_hashref

=head1 EXPORTED FUNCTIONS


B<sth_arrayref( $sth )>

For a prepared and executed statement handle, return an interator which 
returns each row of the query as an ARRAY ref, i.e. B<$sth-E<gt>fetchrow_arrayref>.

B<sth_hashref( $sth )>

For a prepared and executed statement handle, return an interator which 
returns each row of the query as a HASH ref, i.e. B<$sth-E<gt>fetchrow_hashref>.

=cut

1;
