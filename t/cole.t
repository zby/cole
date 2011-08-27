use strict;
use warnings;

use lib 't/cole';

use Test::Spec;

use Foo;

use_ok('Cole');

describe "IOC" => sub {
    my $ioc;

    before each => sub {
        $ioc = Cole->new;
    };

    it "should hold services" => sub {
        $ioc->register( name => 'foo', class => 'Foo' );

        isa_ok($ioc->get('foo'), 'Foo');
    };

    it "should hold constants" => sub {
        $ioc->register( name => 'foo', value => 'hello' );

        is($ioc->get('foo'), 'hello');
    };

    it "should accept instance as a service" => sub {
        $ioc->register( name => 'foo', value => Foo->new );

        isa_ok($ioc->get('foo'), 'Foo');
    };

    it "should return all services on get_all" => sub {
        my $service1 = Foo->new;
        $ioc->register( name => 'foo', value => $service1 );
        my $service2 = Foo->new;
        $ioc->register( name => 'bar', value => $service2 );

        is_deeply([$ioc->get_all], [bar => $service2, foo => $service1,]);
    };

    it "should resolve single dependency" => sub {
        $ioc->register( name => 'foo', class => 'Foo' );
        $ioc->register( name => 'bar', class => 'Bar', deps => 'foo' );

        isa_ok($ioc->get('bar')->foo, 'Foo');
    };

    it "should resolve multiple dependencies" => sub {
        $ioc->register( name => 'foo', value => 'Foo' );
        $ioc->register( name => 'bar', class => 'Bar', deps => 'foo' );
        $ioc->register( name => 'baz', class => 'Baz', deps => ['foo', 'bar'] );

        isa_ok($ioc->get('baz')->foo, 'Foo');
        isa_ok($ioc->get('baz')->bar, 'Bar');
    };

    it "should resolve dependecy and pass it as other name" => sub {
        $ioc->register(name => 'name', value => 'foo' );
        $ioc->register(
            name => 'zzz',
            class => 'Bar',
            deps  => {name => 'foo'}
        );

        my $zzz = $ioc->get('zzz');

        is($zzz->foo, 'foo');
    };

    it "should create via factory" => sub {
        $ioc->register(
            name => 'foo',
            block => sub {'123'}
        );

        is($ioc->get('foo'), '123');
    };

    it "should create via factory and pass deps" => sub {
        $ioc->register( name => 'dep', value => '123' );
        $ioc->register(
            name => 'foo',
            block => sub {
                    my %args = @_;

                    return $args{dep};
            },
            deps => 'dep'
        );

        is($ioc->get('foo'), '123');
    };

    it "should hold singletons" => sub {
        $ioc->register( name => 'foo', class => 'Foo' );
        $ioc->register( name => 'bar', class => 'Bar', deps => 'foo' );

        my $bar = $ioc->get('bar');
        isa_ok($bar,      'Bar');
        isa_ok($bar->foo, 'Foo');

        $bar->hello('there');
        is $bar->hello, 'there';

        $bar = $ioc->get('bar');
        is $bar->hello, 'there';
    };

};

runtests unless caller;
