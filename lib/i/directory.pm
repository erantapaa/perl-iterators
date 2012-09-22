package i::directory;

use strict;
use warnings;
use feature ":5.10";
use i::iter;

use Exporter 'import';
our @EXPORT = qw/dirents files directories/;

# -- Directory Entries

sub dirents {
  my ($dirname) = @_;

  source {
    state $dh = do { my $h; opendir($h, $dirname) ? $h : undef };
    return unless $dh;
    my $leaf = readdir($dh);
    return unless defined $leaf;
    return bless { leaf => $leaf, dirname => $dirname, path => "$dirname/$leaf" }, "i::dirent";
  }
}

sub files {
  transformer {
    my $i = shift;
    my $s = ref($i) ? $i : dirents($i);
    filter { $_->isfile }, $s;
  }
}

sub directories {
  transformer {
    my $i = shift;
    my $s = ref($i) ? $i : dirents($i);
    filter { $_->isdir }, $s;
  }
}

1;

__END__

=pod

=head1 NAME

i::directory - iterator constructors for traversing file system directories.

=head1 SYNOPSIS

  use i::directory;

  my $paths = i::compose( dirents("/bin") => i::map { $_->path } => i::collect() )

=head1 DESCRIPTION

This module defines functions which create iterators over file system directories.

=head1 EXPORTED FUNCTIONS

B<dirents( $path )>

Returns an iterator which returns the entries in the directory B<$path>.
Each entry is represented as a B<i::dirent> object. Only the first level
entries in B<$path> are returned.

B<files( $path )>

B<files( $i )>

Returns an iterator of just the files in the directory B<$path>.
The argument to B<files> may also an iterator producing B<i::dirent> objects
in which case it selects only those representing files.
B<files> may also be called with no arguments to return the uncurried version.

B<directories( $path )>

B<directories( $i )>

Returns an iterator of just the directories in the directory B<$path>.
The argument to B<directories> may also an iterator producing B<i::dirent> objects
in which case it selects only those representing directories.
B<directories> may also be called with no arguments to return the uncurried version.

=head1 SEE ALSO

i::dirent


=cut
