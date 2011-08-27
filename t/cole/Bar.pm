package Bar;

sub new {
    my $class = shift;
        
    my $self = { @_ };
    bless $self, $class; 
    return $self;
}

sub foo { $_[0]->{foo} }

sub hello { @_ > 1 ? $_[0]->{hello} = $_[1] : $_[0]->{hello} }

1;
