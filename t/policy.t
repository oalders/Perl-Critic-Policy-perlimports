#!perl

use strict;
use warnings;

use Perl::Critic ();
use Test2::V0 qw( done_testing is );

use constant POLICY => 'Perl::Critic::Policy::perlimports';

{
    my $pc = Perl::Critic->new( -only => 1 );
    $pc->add_policy(
        -policy => POLICY,
        -params => { ignored_modules => 'Path::Tinier' },
    );

    my $code = <<'EOF';
use strict;
use warnings;

use Path::Tiny;

my $call_my_agent = path('Dix pour cent');
EOF

    my @violations = map { $_->source } $pc->critique( \$code );
    is(
        \@violations,
        [ 'use Path::Tiny;' ],
        'Path::Tiny violation'
    );
}

done_testing();
