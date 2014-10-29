Scope::MonkeyPatch
==================

Monkey patches that revert when they go out of scope

Synopsis
========

    use Scope::MonkeyPatch;

    # Setup
    my $patch = Scope::MonkeyPatch->new({
        package  => "MIME::Lite",
        function => "send",
        code     => sub {
            return "Message sent";
        },
    });

    # Activate the monkey patch
    $patch->activate;

    # run your code
    my $ok = MIME::Lite->new()->send();

    # reset
    $patch->deactivate; # it automatically resets when it goes out of scope

Description
===========

Sometimes you want to test how your code interacts with other code. You
can design around this using stubs or mocks in your own code but sometimes
your code is interacting with 3rd party libraries that you can't change.

C<Scope::MonkeyPatch> lets you stub or mock out a method in another class
in your test cases within the current scope to limit the damage.

Caveats
=======

 * It is not a replacement for good module design
 * Too much mocking may lead to test suites that pass when the code
   is actually broken

See Also
========

 * L<Class::Mockable> tries to solve a similar problem by making it easy
   to shim specific methods in a module that you control. However, in many
   cases you don't control the module that you want to test against.

   L<Scope::MonkeyPatch> makes the tests responsible for mocking
   rather than the module that you are interacting with.

   L<Class::Mockable> also does not support mocking functions that return
   arrays or lists.

Bugs
====

Please report bugs at Github.

License
=======

Scope::MonkeyPatch is Copyright (C) 2014, Andy Jones

This module is free software; you
can redistribute it and/or modify it under the same terms
as Perl 5.10.0. For more details, see the full text of the
licenses in the directory LICENSES.
