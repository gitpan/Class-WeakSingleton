# Class::WeakSingleton.pm
#
# Implementation of a "singleton" module which ensures that a class has
# only one instance and provides global access to it until all the
# references to it go out of scope. For a description of the Singleton class,
# see "Design Patterns", Gamma et al, Addison-Wesley, 1995, ISBN 0-201-63361-2
#
# Written by Joshua b. jore <jjore@cpan.org>
# mostly copied from Class::Singleton by Andy Wardley
#
# Copyright (C) 2003 Joshua b. Jore  All Rights Reserved.

package Class::WeakSingleton;

use strict;
use vars qw( $VERSION );
use Scalar::Util ();

$VERSION = "1.03";

# instance()
# Module constructor. Creates an Class::WeakSingleton (or derivative)
# instance  if one doesn't already exist. A weak reference is stored in
# the $_instance variable of the parent package. This means that classes 
# derived from Class::WeakSingleton will have the variables defined in
# *THEIR* package, rather than the Class::WeakSingleton package. Also,
# because the stored reference is weak it will be deleted when all other
# references to the returned object have been deleted. The first time
# the instance is created, the _new_instance() constructor is called
# which simply returns a reference to a blessed hash. This can be 
# overloaded for custom constructors. Any addtional parameters passed to 
# instance() are forwarded to _new_instance().
#
# Returns a normal reference to the existing, or a newly created
# Class::WeakSingleton object.  If the _new_instance() method returns
# an undefined value then the constructer is deemed to have failed.

sub instance {
    my $class = shift;

    # get a reference to the _instance variable in the $class package
    no strict 'refs';
    my $instance = "${class}::_instance";

    return $$instance if defined $$instance;

    my $new_instance
        = $$instance
        = $class->_new_instance(@_);

    Scalar::Util::weaken( $$instance );

    return $new_instance;
}

# _new_instance(...)
#
# Simple constructor which returns a hash reference blessed into the 
# current class.  May be overloaded to create non-hash objects or 
# handle any specific initialisation required.
#
# Returns a reference to the blessed hash.

sub _new_instance {
    bless { }, $_[0];
}

1;

__END__

=head1 NAME

Class::WeakSingleton - A Singleton that expires when all the references to it expire

=head1 SYNOPSIS

 use Class::WeakSingleton;

 {
     my $c = Class::WeakSingleton->instance;
     my $d = Class::WeakSingleton->instance;
     die "Mismatch" if $c != $d;
 }   # Class::WeakSingleton->instance expires
 {
     my $e = Class::WeakSingleton->instance;
     {
         my $f = Class::WeakSingleton->instance;
         die "Mismatch" if $e != $f;
     }
 }   # Class::WeakSingleton->instance expires

=head1 DESCRIPTION

This is the Class::WeakSingleton module. A Singleton describes an
object class that can have only one instance in any system. An example
of a Singleton might be a print spooler, system registry or database
connection. A "weak" Singleton is not immortal and expires when all other
references to the original instance have expired. This module implements a
Singleton class from which other classes can be derived, just like
Class::Singleton. By itself, the Class::WeakSingleton module does very
little other than manage the instantiation of a single object. In deriving
a class from Class::WeakSingleton, your module will inherit the Singleton
instantiation method and can implement whatever specific functionality is
required.

For a description and discussion of the Singleton class, see L<Class::Singleton>
and "Design Patterns", Gamma et al, Addison-Wesley, 1995, ISBN 0-201-63361-2.

=head1 PREREQUISITES

Class::WeakSingleton requires Scalar::Util with the weaken() function.

=head1 USING THE CLASS::WEAKSINGLETON MODULE

To import and use the Class::WeakSingleton module the following line should 
appear in your Perl script:

    use Class::WeakSingleton;

The instance() method is used to create a new Class::WeakSingleton instance, 
or return a reference to an existing instance. Using this method, it
is only possible to have a single instance of the class in any system
at any given time. The instance expires when all references to it also
expire.

    {
        my $highlander = Class::WeakSingleton->instance();

Assuming that no Class::WeakSingleton object currently exists, this first
call to instance() will create a new Class::WeakSingleton and return a reference
to it.  Future invocations of instance() will return the same reference.

        my $macleod    = Class::WeakSingleton->instance();
    }

In the above example, both $highlander and $macleod contain the same
reference to a Class::Weakingleton instance. There can be only one.
Except that now that both $highlander and $macleod went out of scope
the singleton did also. So MacLeod is now dead. Boo hoo.

=head1 DERIVING WEAKSINGLETON CLASSES

A module class may be derived from Class::WeakSingleton and will
inherit the instance() method that correctly instantiates only one
object.

    package Database;
    use vars qw(@ISA);
    @ISA = qw(Class::WeakSingleton);

    # derived class specific code
    sub user_name { $_[0]->{user_name} }
    sub login {
        my $self = shift;

        my ($user_name, $user_password) = @_;

        # ...

	$self->{user_name} = $user_name;

        1;
    }

The Database class defined above could be used as follows:

    use Database;

    do_somestuff();
    do_somestuff();

    sub do_somestuff {
        my $db = Database->instance();

        $db->login(...);
    }

The instance() method calls the _new_instance() constructor method the 
first and only time a new instance is created (until the instance expires
and then it starts over). All parameters passed to the instance()
method are forwarded to _new_instance(). In the base class this method
returns a blessed reference to an empty hash array.  Derived classes
may redefine it to provide specific object initialisation or change the
underlying object type (to a array reference, for example).

    package MyApp::Database;
    use vars qw( $ERROR );
    use base qw( Class::WeakSingleton );
    use DBI;

    $ERROR = '';

    # this only gets called the first time instance() is called
    sub _new_instance {
	my $class = shift;
	my $self  = bless { }, $class;
	my $db    = shift || "myappdb";    
	my $host  = shift || "localhost";

	unless (defined ($self->{ DB } 
			 = DBI->connect("DBI:mSQL:$db:$host"))) {
	    $ERROR = "Cannot connect to database: $DBI::errstr\n";
	    # return failure;
	    return undef;
	}

	# any other initialisation...

	# return sucess
	$self;
    }

The above example might be used as follows:

    use MyApp::Database;

Some time later on in a module far, far away...

    package MyApp::FooBar
    use MyApp::Database;

    sub new {
	# usual stuff...

	# this FooBar object needs access to the database; the Singleton
	# approach gives a nice wrapper around global variables.

	# new instance is returned
	my $database = MyApp::Database->instance();

	# more stuff...
        # call some methods
    }

    sub some_methods {
        # more usual stuff

        # Get the same object that is used in new()
        my $database = MyApp::Database->instance;
    }

The Class::WeakSingleton instance() method uses a package variable to
store a reference to any existing instance of the object. This variable, 
"_instance", is coerced into the derived class package rather than
the base class package.

Thus, in the MyApp::Database example above, the instance variable would
be:

    $MyApp::Database::_instance;

This allows different classes to be derived from Class::WeakSingleton
that can co-exist in the same system, while still allowing only one
instance of any one class to exists.  For example, it would be possible
to derive both 'Database' and 'MyApp::Database' from Class::WeakSingleton
and have a single instance of I<each> in a system, rather than a single 
instance of I<either>.

=head1 AUTHOR

Joshua b. Jore C<E<lt>jjore@cpan.orgE<gt>>

Thanks to Andy Wardley for writing Class::Singleton.

=head1 COPYRIGHT

Copyright (C) 2003 Joshua b. Jore. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under 
the term of the Perl Artistic License.

=head1 SEE ALSO

=over 4

=item L<Class::Singleton>

=item Design Patterns

Class::WeakSingleton is an implementation of the Singleton class described in 
"Design Patterns", Gamma et al, Addison-Wesley, 1995, ISBN 0-201-63361-2

=back

=cut
