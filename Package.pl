use Module::Package;
my $pack = Module::Package->new(
    name => 'Pod::Site',
    version_from => 'lib/Pod/Site.pm',
    prereq_pm => {
        'Moose' => 0,
        'MooseX::NonMoose' => 0,
        'MooseX::SemiAffordanceAccessor' => 0,
        'MooseX::StrictConstructor' => 0,
        'MooseX::Types' => 0,
        'Pod::POM' => 0,
    },
    abstract_from => 'lib/Pod/Site.pm',
    author => 'Jeffrey Ray Hallock <jeffrey dot hallock at gmail dot com>',
    exclude => [ '*.komodoproject', '.komodotools', '.git' ],
);
$pack->package;


