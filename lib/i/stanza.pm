package i::stanza;

use strict;
use warnings;
use i::iter;

use Exporter 'import';
our @EXPORT_OK = qw/stanzas stanzas_start_matching/;

# return stanzas delimited by a starting regular expression

sub stanzas {
  my ($start_re, $fh) = @_;

  my $buf = "";
  source {
    return unless defined($buf);
    while (<$fh>) {
      if (m/$start_re/) {
        my $r = $buf;
        $buf = $_;
        return $r if length($r);
      }
      $buf .= $_;
    }
    if (length($buf)) {
      my $r = $buf;
      $buf = undef;
      return $r;
    }
    return;
  };
}

sub stanzas_start_matching {
  my ($start_re, $match_re, $fh) = @_;

  # Note - a line matching $match_re must also match $start_re

  my $buf = "";
  my $line = "";
  source {
    if (defined($line) && $line =~ m/$match_re/) {
      $buf = $line;
      $line = undef;
      while (<$fh>) {
        if (m/$start_re/) {
          $line = $_; last;
        } else {
          $buf .= $_;
        }
      }
      return $buf;
    }
    $line = undef;
    while (<$fh>) {
      if (m/$match_re/) {
        $buf = $_;
        while (<$fh>) {
          if (m/$start_re/) {
            $line = $_; last;
          } else {
            $buf .= $_;
          }
        }
        return $buf;
      }
    }
    return;
  };
}

=pod

=head1 NAME

i::stanza

=head1 SYNOPSIS

  use i::stanza;

  stanzas( qr/some re/, $fh )

=head1 DESCRIPTION

A stanza is a group of consecutive lines in a file. This module provides iterator constructors
for parsing stanzas from a file handle.

=head1 EXPORTED FUNCTIONS

B<stanza( $re, $fh )>

Return an interator which yield successive stanzas from a file handle.
The parameter B<$re> is a regular expression which is used to determine
if a line begins a stanza.

The start of the stanza is the first line read from the file handle which matches
the regular expression B<$re>. It continues until another line is read which matches
B<$re> or end of file is reached. The stanza is returned as single string, including
any intermediate newlines.

=cut

1;

