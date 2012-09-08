package i::open;

sub openread {
  my ($path) = @_;
  return $path if ref($path);
  my $fh;
  if (open($fh, "<", $path)) {
    return $fh;
  }
  Carp::cluck("unable to read $path: $!");
  return;
}

sub openwrite {
  my ($path) = @_;
  return $path if ref($path);
  my $fh;
  if (open($fh, ">", $path)) {
    return $fh;
  }
  Carp::cluck("unable to write $path: $!");
  return;
}

1;

