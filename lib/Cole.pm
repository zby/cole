package Cole;

use strict;
use warnings;

our $VERSION = '0.009001';

require Carp;
use Class::Load ();

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub register {
    my $self = shift;
    my %args = @_;

    Carp::croak('Service name is required') unless $args{name};
    if( my $class = $args{class} ){
        $args{block} = sub { 
            Class::Load::load_class( $class );
            $class->new( @_ ) 
        };
    }

    $self->{services}->{$args{name}} = {%args};    # Shallow copy
    return $self;
}

sub get {
    my $self = shift;
    my ($key) = @_;

    my $service = $self->_get( $key );

    if ( !exists $service->{value} ) {
        my %args = $self->_build_deps( $service );
        $service->{value} = $service->{block}->( %args );
    }
    return $service->{value};
}

sub get_all {
    my $self = shift;

    my @services;
    foreach my $service (keys %{$self->{services}}) {
        push @services, $service => $self->get($service);
    }

    return @services;
}

sub _get {
    my $self = shift;
    my ($key) = @_;

    die "Service '$key' does not exist"
      unless exists $self->{services}->{$key};

    return $self->{services}->{$key};
}


sub _build_deps {
    my $self = shift;
    my ($service) = @_;

    if (my $deps = $service->{deps}) {
        $deps = [$deps] unless ref $deps eq 'ARRAY';

        my %args;
        foreach my $dep (@$deps) {
            my ($key, $value) = ($dep, $dep);

            if (ref $dep eq 'HASH') {
                $key   = (values(%$dep))[0];
                $value = (keys(%$dep))[0];
            }

            $args{$key} = $self->get($value);
        }

        return %args;
    }

    return ();
}

1;
__END__

=head1 NAME

Cole - Lightweight DI container

=head1 SYNOPSIS

    $ioc = Cole->new;

    $ioc->register( name => 'class name', class => 'Foo');
    $ioc->register( name => 'string', 'Hello, world!');
    $ioc->register( name => 'instance',   Foo->new);

    $ioc->register( name => 'dependency', class => 'Bar', deps => 'foo');
    $ioc->register(
        name => 'multiple dependencies',
        class => 'Baz',
        deps  => ['foo', 'bar']
    );

=head1 DESCRIPTION

L<Cole> is a lightweight Dependency Injection container.

=head1 FEATURES

=head2 C<Values>

    $ioc->register( name => my_string, value => 'Hello world!' );
    $ioc->register( name => foo_instance, value => Foo->new );

=head2 C<Class names>

    $ioc->register( name => foo, class => 'Foo' );

=head2 C<Dependencies>

    $ioc->register( name => foo, class => 'Foo', deps => 'bar' );

=head2 C<Aliases>

    $ioc->register( name => bar, class => 'Bar' );
    $ioc->register( name => foo, class => 'Foo', deps => { bar => 'baz' } );

C<bar> is passed as C<baz> during C<Foo> creation.

=head1 METHODS

=head2 C<new>

    my $ioc = Cole->new;

=head2 C<register>

    $ioc->register( name => some_name, class => 'foo' );

Register a new dependency.

=head2 C<get>

    $ioc->get('name');

Return an instance of a service by name.

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/vti/cole

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
