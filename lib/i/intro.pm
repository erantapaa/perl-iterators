package i::intor;

=head1 NAME

i - an iterator library

=head1 DESCRIPTION

This module implements 'pull'-style iterators. An pull-iterator is simply a CODE ref
which will return the next value in a stream of values every time it is called.
When the iterator has no more values to yield it returns B<undef>.

=head1 ITERATOR TYPES

There are three kinds of iterators:

=over 4

=item SOURCES

=item TRANSFORMERS

=item SINKS

=back

SOURCES appear at the beginning of an iterator chain and produce values without requiring
input from another iterator.

TRANSFORMERS take an iterator as input to create a new iterator.
TRANSFORMERS appear in the middle of an iterator chain.

Like TRANSFORMERS, SINKS take an iterator as input, but do not create a new iterator.
SINKS may only appear at the end of an iterator chain.

Examples of each kind of iterator:

  my $source = sub { state $n = 4; $n ? $n-- : undef }

  my $sink = sub { my $i = shift;
                   while (defined(my $x = $i->())) {
                     print $x, " ";
                   }
                   print "\n";
                 }

  my $filter = sub { my $i = shift;
                     sub {
                       while (defined(my $x = $i->())) {
                         next unless $x % 2 == 0;
                         return 10*$x;
                       }
                      }
                    }

The iterator B<$source> will yield the values 4, 3, 2 and 1 before returning B<undef>
which is the signal that the stream has been exhausted.

The transformer B<$filter> reads from an input iterator, filters out those values
which are even and otherwise returns a function (in this case 10*$x) of the input stream value.

The sink B<$sink> reads from an input iterator and prints out each value from that stream.

Strictly speaking TRANSFORMERS and SINKS are not iterators themselves but functions of
iterators. Hopefully this won't be too confusing.

=head1 COMPOSING ITERATORS

SOURCES, TRANSFORMERS and SINKS may be composed together to form new iterators
using the function B<i::compose>.

Examples:

    i::compose( $source => $sink )
      -- prints: 4 3 2 1

    i::compose( $source => $filter => $sink )
      -- prints: 40 20

    i::compose( $source => $filter => $filter => $sink )
      -- prints: 400 200

It's up to the user to make sure that the composition makes sense.
In general a chain of iterators may be composed if each pair of iterators in the chain
is either:

=over 4

=item
a SOURCE feeding into a TRANSFORMER

=item
a SOURCE feeding into a SINK

=item
a TRANSFORMER feeding into another TRANSFORMER

=item
a TRANSFORMER feeding into a SINK

=back

=cut

1;

