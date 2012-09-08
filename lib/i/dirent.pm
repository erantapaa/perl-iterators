package i::dirent;

use strict;
use warnings;
use File::stat;

sub leaf {
  shift->{leaf};
}

sub dirname {
  shift->{dirname};
}

sub path {
  shift->{path}
}

sub st {
  my $self = shift;
  $self->{st} //= File::stat::stat($self->{path});
}

sub isfile {
  my $self = shift;
  (my $st = $self->st) && -x $st;
}

sub isdir {
  my $self = shift;
  (my $st = $self->st) && -d $st;
}

1;

