package Perl::Critic::Policy::perlimports;

use strict;
use warnings;

use parent 'Perl::Critic::Policy';

use Perl::Critic::Utils qw( $FALSE $SEVERITY_LOW $TRUE );
use Try::Tiny qw( catch try );

use constant DESC => 'perlimports violation';
use constant EXPL => 'Your import (use) statements should be explicit where possible and not import anything which is not used';

sub applies_to { 'PPI::Document' }

sub default_severity { $SEVERITY_LOW }

sub initialize_if_enabled {
    my ($self) = @_;

    require App::perlimports::Document;
    require File::Which;
    require Log::Dispatch;

    my $binary = File::Which::which('perlimports');
    if ( !$binary ) {
        return $FALSE;
    }

    my $err;
    try {
        # We need our own patched version of PPI in order to get the most
        # accurate results.
        require $binary;
    }
    catch {
        $err = $_;
    };

    if ( $err && $err !~ qr{Compilation failed} ) {
        return $FALSE;
    }

    return $TRUE;
}

sub violates {
    my ( $self, $perl_critic_document ) = @_;

    my $logger = Log::Dispatch->new(
        outputs => [
            [ 'Screen', min_level => 'warning' ],
        ]
    );

    my $orig = $perl_critic_document->ppi_document->serialize . q{};

    my $doc = App::perlimports::Document->new(
        filename     => $perl_critic_document->filename || 'no-file-exists',
        logger       => Log::Dispatch->new,
        ppi_document => $perl_critic_document->ppi_document,
    );

    print STDOUT $doc->tidied_document;

    if ( $orig ne $doc->tidied_document ) {
        return $self->violation( DESC, EXPL, $perl_critic_document->ppi_document );
    }

    return ();
}

1;

# ABSTRACT: Enforce perlimports via perlcritic
