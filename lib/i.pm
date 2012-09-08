package i;

use strict;
use warnings;
use feature ":5.10";
use d ();
use Carp;
use i::curry;
use i::iter;

# Composition

sub compose {
  die "compose requires at least one argument" unless @_;
  my $i = shift;
  for (@_) { $i = $_->($i) }
  return $i;
}

# Sinks

sub run_ : curry1(run) {
  my $i = shift;
  while (defined($i->())) { }
  return;
}

sub trace_ : curry1(trace) {
  my $i = shift;
  iter {
    my $x = $i->();
    if (defined($x)) {
      print STDERR d::d($x), "\n";
    }
    return $x;
  };
}

sub collect_ : curry1(collect) {
  my ($i) = @_;
  my @a;
  while (defined(my $x = $i->())) {
    push(@a, $x);
  }
  return \@a;
}

sub do_ (&$) : curry2code(do) {
  my ($f, $i) = @_;
  while (defined(my $x = $i->())) {
    { local $_ = $x;
      $f->($x);
    };
  }
  return;
}

# Transformers

sub filter_ (&$) : curry2code(filter) {
  my ($f, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      { local $_ = $x;
        return $x if $f->($x);
      }
    }
    return;
  }
}

sub map_ (&$) : curry2code(map) {
  my ($f, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      { local $_ = $x;
        my $y = $f->($x);
        return $y if defined($y);
      }
    }
    return;
  }
}

sub tap_ (&$) : curry2code(tap) {
  my ($f, $i) = @_;
  iter {
    local $_ = $i->();
    if (defined($_)) {
      $f->($_);
    }
    return $_;
  }
}

sub take_ : curry1(take) {
  my ($n, $i) = @_;
  iter {
    return unless $n-- > 0;
    my $x = $i->();
    return $x if defined($x);
    $n = 0;
    return;
  }
}

sub concat {
  my ($i) = @_;
  my $j;
  iter {
    while (my $j //= $i->()) {
      my $x = $j->();
      return $x if defined($x);
    }
  }
}

# Sources

# -- Ranges

sub upto {
  if (@_ == 1) {
    return _range_unbounded($_[0], 1);
  } elsif (@_ == 2) {
    return _range_pos($_[0], $_[1], 1);
  } elsif (@_ == 3) {
    my ($x, $y, $step) = @_;
    carp "downto: step is not >= 0: ".$step;
    return _range_neg($x, $y, $step);
  } else {
    croak "upto: unexpected number of arguments (".scalar(@_).")";
  }
}

sub downto {
  if (@_ == 1) {
    return _range_unbounded($_[0], -1);
  } elsif (@_ == 2) {
    return _range_neg($_[0], $_[1], -1);
  } elsif (@_ == 3) {
    my ($x, $y, $step) = @_;
    carp "downto: step is not >= 0: ".$step;
    return _range_neg($x, $y, -$step);
  } else {
    croak "downto: unexpected number of arguments (".scalar(@_).")";
  }
}

sub fromto {
  unless (@_ == 2 || @_ == 3) {
    croak "fromto: unexpected number of arguments (".scalar(@_).")";
  }
  my ($x, $y, $step) = @_;
  unless (defined($step)) {
    $step = ($x >= $y ? 1 : -1);
  }
  if ($step >= 0) {
    return _range_pos($_[0], $_[1], $step);
  } else {
    return _range_neg($_[0], $_[1], $step);
  }
}

sub range {
  # range($n) => _range_unbounded($n,1)
  # range($n, $m) => _range_{pos/neg}($n, $m, +/-1)
  # range($n, $m, $step) => _range_{pos/neg}($n, $m, $step)
  if (@_ == 1) {
    return _range_unbounded($_[0], 1);
  } elsif (@_ == 2 || @_ == 3) {
    my ($x, $y, $z) = @_;
    unless (defined($z)) {
      $z = defined($y) ? ($y >= $x ? 1 : -1)
                       : 1;
    }
    # $x and $z are defined
    if (defined($y)) {
      if ($z >= 0) {
        return _range_pos($x, $y, $z);
      } else {
        return _range_neg($x, $y, $z);
      }
    } else {
      return _range_unbounded($x, $z);
    }
  } else {
    die "too many arguments to range: ".d(\@_);
  }
}

sub _range_pos {
  my ($from, $to, $step) = @_;
  iter {
    return if $from > $to;
    my $r = $from;
    $from += $step;
    return $r;
  }
}

sub _range_neg {
  my ($from, $to, $step) = @_;
  iter {
    return if $from < $to;
    my $r = $from;
    $from += $step;
    return $r;
  }
}

sub _range_unbounded {
  my ($from, $step) = @_;
  iter {
    my $r = $from;
    $from += $step;
    return $r;
  }
}

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

# -- Lines from files

sub lines ($) {
  my $fh = shift;
  iter {
    readline($fh);
  }
}

sub chomped_lines {
  my $fh = shift;
  iter {
    if (defined(my $x = readline($fh))) {
      chomp $x;
      return $x;
    }
    return;
  }
}

# -- Arrays and Hashes

sub array {
  my $a = shift;
  my $k = 0;
  iter {
    return unless ($k <= $#$a);
    return $a->[$k++];
  }
}

sub array_pairs {
  my $a = shift;
  my $k = 0;
  iter {
    return unless ($k <= $#$a);
    my $r = [$k, $a->[$k]];
    $k++;
    return $r;
  }
}

sub hash_pairs {
  my $h = shift;
  iter {
    while (my ($k,$v) = each %$h) {
      return [$k,$v];
    }
    return;
  }
}

# -- ARGV / <>

sub ARGV { array(\@ARGV) }

sub diamond {
  iter {
    while (<>) { return $_ }
    return;
  }
}

sub chomped_diamond {
  iter {
    while (<>) { chomp; return $_ }
    return;
  }
}

sub sayd_ : curry1(sayd) {
  my $i = shift;
  i::do { say d::d($_) } $i;
}

# -- Regular Expressions

sub matches_named_ : curry1(matches_named) {
  my ($re, $i) = @_;
  my $line;
  iter {
    while () {
      unless (defined($line)) {
        $line = $i->();
        return unless defined($line);
      }
      while ($line =~ m/$re/g) {
        return { %+ };
      }
      $line = undef;
    }
  }
}

sub matches_array_ : curry2(matches_array) {
  my ($re, $i) = @_;
  my $line;
  iter {
    while () {
      unless (defined($line)) {
        $line = $i->();
        return unless defined($line);
      }
      if ($line =~ m/$re/g) {
        return [ map { substr($line, $-[$_], $+[$_] - $-[$_]) } (1..$#-) ];
      }
      $line = undef;
    }
  }
}

sub match_once_named_ : curry2(match_once_named) {
  my ($re, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      if ($x =~ m/$re/) {
        return { %+ };
      }
    }
    return;
  }
}

sub match_once_array_ : curry2(match_once_array) {
  my ($re, $i) = @_;
  iter {
    while (defined(my $x = $i->())) {
      next unless $x =~ m/$re/;
      return [ map { substr($x, $-[$_], $+[$_] - $-[$_]) } (1..$#-) ];
    }
    return;
  }
}

1;

