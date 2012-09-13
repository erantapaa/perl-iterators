package i::dirent;

use strict;
use warnings;
use feature ':5.10';
use File::stat ();
use File::Basename ();
use File::Spec::Functions qw/catfile/;

sub new {
  my $class = shift;
  bless {@_}, $class;
}

sub leaf {
  my $self = shift;
  $self->{leaf} //= basename( $self->{path} );
  };
}

sub dirname {
  my $self = shift;
  $self->{dirname} //= File::Basename::dirname( $self->{path} );
}

sub path {
  my $self = shift;
  $self->{path} //= catfile($self->{dirname}, $self->{leaf});
}

sub st {
  my $self = shift;
  $self->{st} //= File::stat::stat($self->path);
}

sub isfile {
  my $self = shift;
  (my $st = $self->st) && -x $st;
}

sub isdir {
  my $self = shift;
  (my $st = $self->st) && -d $st;
}

=pod

=head1 NAME

i::dirent - object representing a directory entry

=head1 SYNOPSIS

  use i::dirent;
  my $d1 = i::dirent->new(path => "/usr/bin/echo");
  my $d2 = i::dirent->new(dirname => "/usr/bin", leaf => "echo");

  say "leaf: " . $d1->leaf;  # derived from path
  say "path: " . $d2->path;  # derived from dirname and leaf

  say "mode: " . $d1->st->mode;

  say $d1->path." is a file" if $d1->isfile;
  say $d1->path." is a directory" if $d1->isdir;

=head1 DESCRIPTION

This module implements a dirent entry which is the class
of objects returned by the B<i::directory> iterators.

=head1 METHODS

B<new( path =E<gt> $path )

B<new( leaf =E<gt> $leaf, dirname =E<gt> $dirname )

Construct a new B<dirent> object by specifying its path name.
Alternatively the leaf and dirname may be specified.

B<path>

Return the path name of the directory entry.
This will be derived from the B<leaf> and B<dirname>
if B<path> was not present in the constructor call.

B<leaf>

Return the leaf name of the directory entry.
This will be derived from the B<path> attribute if
B<leaf> was not present in the contructor call.

B<dirname>

Return the dirname name of the directory entry.
This will be derived from the B<path> attribute if
B<dirname> was not present in the contructor call.

B<st>

Return the B<File::stat> object for this path.
Once called, this result will be cached for the lifetime
of the dirent object.

B<isfile>

Return true if the path is a file.

B<isdir>

Return true if the path is a directory.

=head1 SEE ALSO

i::directory


=cut

1;
