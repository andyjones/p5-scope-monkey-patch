package Scope::MonkeyPatch;

use Moo;

has [qw/code package function/] => is => 'ro', required => 1;

has _original_code => is => 'rw';

# returns true if the monkey patch is in place
sub _active {
    my $self = shift;
    return $self->_original_code
        && $self->_current_code == $self->code;
}

sub _current_code {
    my $self = shift;
    return $self->package->can($self->function)
        || die "Won't monkey patch ".$self->function." in ".$self->package.
               " because it doesn't exist";
}

sub activate {
    my $self = shift;

    if ( $self->_active ) {
        warn $self->function." is already monkeypatched";
        return $self;
    }

    $self->_original_code($self->_current_code);
    $self->_install_code($self->_full_package, $self->code);

    return $self;
}

sub deactivate {
    my $self = shift;

    if ( !$self->_active ) {
        die "Can't deactivate an inactive monkey patch!";
    }

    $self->_install_code($self->_full_package, $self->_original_code);

    return $self;
}

sub _full_package {
    my $self = shift;
    return $self->package . '::' . $self->function;
}

sub _install_code {
    my ($self, $full_package, $code) = @_;

    no strict 'refs';
    no warnings 'redefine';
    *{$full_package} = $code;
}

sub DEMOLISH {
    my ($self, $global_destruction) = @_;
    $self->deactivate if $self->_active;
}

1;
