use strict;
use warnings;

package Setters;

sub new { 
    my $class = shift;

    my $self = { @_ };
    bless $self, $class; 
    return $self; 
}

sub set_foo {$_[0]->{value} = $_[1]}
sub get_foo {$_[0]->{value}}

1;
