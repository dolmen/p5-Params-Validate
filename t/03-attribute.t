use strict;

BEGIN
{
    if ($] < 5.006)
    {
	print "1..0\n";
	exit;
    }
}

print "1..10\n";

use Attribute::Params::Validate qw(:types);

sub foo :Validate( c => { type => SCALAR } )
{
    my %data = @_;
    return $data{c};
}

sub bar :Validate( c => { type => SCALAR } ) method
{
    my $self = shift;
    my %data = @_;
    return $data{c};
}

sub baz :Validate( foo => { type => ARRAYREF, callbacks => { '5 elements' => sub { @{shift()} == 5 } } } )
{
    my %data = @_;
    return $data{foo}->[0];
}

my $res = eval { foo( c => 1 ) };
ok( ! $@,
    "Calling foo with a scalar failed: $@\n" );

ok( $res == 1,
    "Return value from foo( c => 1 ) was not 1, it was $res\n" );

eval { foo( c => [] ) };

ok( $@,
    "No exception was thrown when calling foo( c => [] )\n" );

ok( $@ =~ /The 'a' parameter to .* was an 'arrayref'/,
    "The exception thrown when calling foo( c => [] ) was $@\n" );

$res = eval { main->bar( c => 1 ) };
ok( ! $@,
    "Calling bar with a scalar failed: $@\n" );

ok( $res == 1,
    "Return value from bar( c => 1 ) was not 1, it was $res\n" );

eval { baz( foo => [1,2,3,4] ) };

ok( $@,
    "No exception was thrown when calling baz( foo => [1,2,3,4] )\n" );

ok( $@ =~ /The 'foo' parameter to .* did not pass the '5 elements' callback/,
    "The exception thrown when calling baz( foo => [1,2,3,4] ) was $@\n" );

$res = eval { baz( foo => [5,4,3,2,1] ) };

ok( ! $@,
    "Calling baz( foo => [5,4,3,2,1] ) threw an exception: $@\n" );

ok( $res == 5,
    "The return value from baz( foo => [5,4,3,2,1] ) was $res\n" );

sub ok
{
    my $ok = !!shift;
    use vars qw($TESTNUM);
    $TESTNUM++;
    print "not "x!$ok, "ok $TESTNUM\n";
    print "@_\n" if !$ok;
}
