package Pod::Site;
our $VERSION = '0.03.1';

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;

use File::Path qw( make_path );

use Pod::POM;
use Pod::POM::View::HTML;
use Pod::POM::View::Text;

use Pod::Site::Types qw( View );
use Pod::Site::View::HTML;


has 'dir' => (
    is => 'rw',
    isa => 'Str',
    default => '.',
);

has 'uri' => (
    is => 'rw',
    isa => 'Str',
    default => '.',
);

has 'verbose' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'view' => (
    is => 'rw',
    isa => View,
    default => sub { Pod::Site::View::HTML->new( site => $_[0] ) },
    trigger => sub { $_[1]->set_site( $_[0] ) },
    coerce => 1,
);

has '_parser' => (
    is => 'rw',
    isa => 'Pod::POM',
    lazy_build => 1,
    handles => [qw( parse_file )]
);


sub _build__parser {
    Pod::POM->new
}

sub install_file {
    my ( $self, $file, $destination ) = @_;
    
    
    my $pom = $self->parse_file( $file );
    
    if ( ! $destination ) {
        $destination = $file;
        $destination =~ s/\..+$/.html/;
    }
    
    my $path = $self->dir ? $self->dir . '/' : '';
    $path .= $destination;
    $path =~ /(.*)\//;
    
    my $dir_path = $1;
    
    # if we have a dir path
    # and the dir does not exist
    if ( $dir_path && ! ( -e $dir_path && -f $dir_path ) ) {
        # create the dir path
        make_path( $dir_path );
    }
    
    open my $OUTPUT, qq[>$path]
        or die qq[Could not open $path for writing];
    flock $OUTPUT, 2;
    print $OUTPUT $pom->present( $self->view );
    close $OUTPUT;
}

sub install_dir {
    
    my ( $self, $dir ) = @_;
    
    my $dirx = quotemeta $dir;
    
    use File::Find;
    
    my @files;
    my $wanted = sub {
        no warnings;
        
        if ( /.*\.(pl|pm|pod)/i ) {
            my $file = $File::Find::name;
            #$file =~ s/^$dir\/?//;
            push @files, $file;
        }
    };
    
    find( $wanted, $dir );

    for my $file ( @files ) {
        my $destination = $file;
        
        $destination =~ s/^$dirx\/?//;
        $destination =~ s/\..*$/.html/;
        $self->install_file( $file, $destination );
    }

}




1;



__END__

=head1 NAME

Pod::Site - Create websites from pod

=head1 SYNOPSIS

  use Pod::Site;

  my $site = Pod::Site->new;

  $site->set_dir( '/path/to/site' );

  $site->set_uri( 'http://localhost/site' );

  $site->install_file( 'path/to/Foo/Bar.pm', 'Foo/Bar.html' );

  $site->install_dir( 'lib' );

=head1 DESCRIPTION

L<Pod::Site> helps you create a web site of documentation.

Most of the work is done by L<Pod::POM>. L<Pod::POM> takes care of parsing
the pod and creating the html output. L<Pod::Site> manages what pod files
to parse and where to store the output.


=head1 PROVIDED ATTRIBUTES

=over 4

=item B<dir>

Directory in which to create generated html files.

=over 4

=item is rw

=item isa Str

=item default %MYDOCUMENTS%/pod

=back

=item B<uri>

The prefix to use when generating links in html files. Use this option if you
want your links to start with http:// instead of file:///.

=over 4

=item is rw

=item isa Str

=item default file:///%MYDOCUMENTS%/pod

=back

=item B<view>

=over 4

=item is rw

=item isa Pod::POM::View::HTML

=item default Pod::Site::View::HTML

=back

=back

=head1 AUTHOR

Jeffrey Ray Hallock E<lt>jeffrey.hallock at gmail dot comE<gt>

=head1 COPYRIGHT

    Copyright (c) 2010-2011 Jeffrey Ray Hallock. All rights reserved.

=cut
