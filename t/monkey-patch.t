use Test::Most;
use Capture::Tiny 'capture_stderr';

use_ok 'Scope::MonkeyPatch';

BEGIN {
    package PackageUnderTest;

    sub method_with_side_effects {
        return 'dragons';
    }
};

my %default_options = (
    code     => sub { 'unicorns' },
    package  => "PackageUnderTest",
    function => "method_with_side_effects",
);

subtest "it doesn't affect the original method" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);
    is PackageUnderTest::method_with_side_effects() => 'dragons';
};

subtest "it monkey patches the method when activated" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);
    $patch->activate;
    is PackageUnderTest::method_with_side_effects() => 'unicorns';
};

subtest "it restores the original method when deactivated" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);
    $patch->activate->deactivate;
    is PackageUnderTest::method_with_side_effects() => 'dragons';
};

subtest "it restores the original method when it goes out of scope" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);

    $patch->activate;
    is PackageUnderTest::method_with_side_effects => 'unicorns';
    $patch = undef;
    is PackageUnderTest::method_with_side_effects => 'dragons';
};

subtest "it dies if you deactivate when it is not active" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);

    dies_ok { $patch->deactivate; }
};

subtest "it warns if you activate it when it is already active" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);

    my $stderr = capture_stderr(sub {
        $patch->activate->activate->activate;
    });
    ok $stderr;
};

subtest "activate is idempotent" => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);
    capture_stderr(sub {
        $patch->activate->activate->activate->deactivate;
    });
    is PackageUnderTest::method_with_side_effects => 'dragons';
};



subtest "it blows up when you monkeypatch a package that doesn't exist" => sub {
    my $patch = Scope::MonkeyPatch->new({
        package  => "SomeMissingPackage",
        function => "some_function",
        code     => sub { "doesn't matter" },
    });

    dies_ok { $patch->activate };
};

subtest "it blows up when you monkeypatch a method that doesn't exist" => sub {
    my $patch = Scope::MonkeyPatch->new({
        package  => "PackageUnderTest",
        function => "some_function",
        code     => sub { "doesn't matter" },
    });

    dies_ok { $patch->activate };
};

subtest "it does not warn when destroyed" => sub {
    my $stderr = capture_stderr(sub {
        my $patch = Scope::MonkeyPatch->new({
            package  => "PackageUnderTest",
            function => "some_function",
            code     => sub { "doesn't matter" },
        });
    });
    ok !$stderr;
};

# Private implementation details
subtest 'it can build the full package name' => sub {
    my $patch = Scope::MonkeyPatch->new(\%default_options);
    is $patch->_full_package => 'PackageUnderTest::method_with_side_effects';
};

done_testing;
