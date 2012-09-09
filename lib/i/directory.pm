package i::directory;

use strict;
use warnings;
use feature ":5.10";
use i::curry;
use i::iter;

use Exporter 'import';
our @EXPORT = qw/dirents files directories/;

# -- Directory Entries

sub dirents {
  my ($dirname) = @_;

  iter {
    state $dh = do { my $h; opendir($h, $dirname) ? $h : undef };
    return unless $dh;
    my $leaf = readdir($dh);
    return unless defined $leaf;
    return bless { leaf => $leaf, dirname => $dirname, path => "$dirname/$leaf" }, "i::dirent";
  }
}

sub files_ : curry1(files) {
  my $i = shift;
  my $s = ref($i) ? $i : dirents($i);
  filter { $_->isfile }, $s;
}

sub directories_ : curry1(directories) {
  my $i = shift;
  my $s = ref($i) ? $i : dirents($i);
  filter { $_->isdir }, $s;
}

1;
