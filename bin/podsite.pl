#!/usr/bin/perl -w
use warnings;
use strict;

use Cwd;
use Pod::Site;

use File::HomeDir;
use Getopt::Long;



# get command line arguments
my ( $dir, $uri, @items );
GetOptions( 'd|dir=s' => \$dir, 'u|uri=s' => \$uri, 'p=s' => \@items );
push @items, @ARGV;


if ( ! @items ) {
    print qq[\n  usage: perl podsite.pl [-options] [files] \n\n];
    print qq[Options:\n];
    print qq[  -d\t--dir\t target directory for .html files\n];
    print qq[  -u\t--uri\t uri to use for links in generated files\n\n];
    print qq[  The default location to generate files is in the user's documents folder.\n];
    exit;
}

# if no dir, use the users default directory
if ( ! $dir ) {
    my $path = File::HomeDir->my_documents;
    $path .= '\pod';
    
    # create the default directory if necessary
    if ( ! -d $path ) {
	mkdir $path or die "Could not create $path.";
    }
    
    $dir = $path;
    $uri = $path;
    $uri =~ s/\\/\//g;
    $uri = 'file:///' . $uri;
}


# run the  pod
my $site = Pod::Site->new( dir => $dir, uri => $uri );
#$site->set_view('My::View::HTML');

for my $path ( @items ) {
    
    if ( ! -e $path ) {
	print "File does not exist: $path\n";
	next;
    }
    elsif ( -f $path ) {
	$site->install_file( $path );
    }
    elsif ( -d $path ) {
	$site->install_dir( $path );
    }
}
