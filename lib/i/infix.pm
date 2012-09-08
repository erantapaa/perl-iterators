
package i::infix;

use strict;
use warnings;

1;

package i::t;

use overload '|' => &pipe;

sub pipe {
  my ($x, $y) = @_;
  bless sub { 
}

1;
