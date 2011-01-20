#!/usr/bin/perl -w

package My::View::HTML;
use Moose;
use MooseX::Types::Moose qw( Str );
extends qw( Pod::Site::View::HTML );

my $style = <<END_STYLE;
<style type="text/css">
body {
    font-size: 14px;
    font-family: calibri, arial;
    background-color: white;
}
pre {
    padding: 5px;
    border: 1px solid black;
    background-color: lightgrey;
    font-size: 11px;
    width: 80%;
}

.pod-content {
    width: 800px;
}
</style>
END_STYLE

sub view_pod {
    my ($self, $pod) = @_;
    return qq[<html>\n]
        . qq[<head>\n]
        . $style
        . qq[</head>\n]
        . qq[<body>\n]
        . qq[<div class="pod-content">\n]
        #. qq[<link href="mystyle.css" rel="stylesheet" type="text/css"></link>\n]
 	. $pod->content->present($self)
        . qq[</div>\n]
        . qq[</body>\n]
        . qq[</html>\n];
}


sub view_seq_link {
    my ($self, $link) = @_;
    
    if ( $link =~ /(\w|:)+/ ) {
        my ($loc, $text) = ($link, $link);
        $loc =~ s/::/\//g;
        
        my $path = $self->site->dir ? $self->site->dir . '/' : '';
        $path .= $loc;
        
        if ( -e $path ) {
            my $uri = $self->site->uri ? $self->site->uri . '/' : '';
            $uri .= $loc . '.html';
            return qq[<a href="$uri">$text</a>\n];
        }
        else {
            my $uri = qq[http://search.cpan.org/perldoc?$text];
            return qq[<a href="$uri">$text</a>\n];
        }
    }
    else {
        return $self->SUPER::view_seq_link( @_ );
    }
}


package main;
use Cwd;
use warnings;
use strict;

use Test::More 'no_plan';

use_ok 'Pod::Site';

my $site = Pod::Site->new( dir => 't/site', uri => 'C:/devel/modules/pod-site/t/site' );
ok $site, 'created site object';
ok $site->dir, 'set site directory';
ok $site->uri, 'set site directory';

$site->set_view( 'My::View::HTML' );

ok $site->parse_file( 'lib\Pod\Site.pm' ), 'parsed file';

$site->install_dir( 'lib' );