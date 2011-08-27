use strict;
use warnings;

package Baz;

sub new { 
    my $class = shift;

    my $self = { @_ };
    bless $self, $class; 
    return $self; 
}

sub foo { $_[0]->{foo} }
sub bar { $_[0]->{bar} }

1;
