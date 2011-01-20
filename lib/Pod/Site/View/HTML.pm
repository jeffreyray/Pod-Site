package Pod::Site::View::HTML;
use Moose;
use MooseX::NonMoose;
extends 'Pod::POM::View::HTML';

use MooseX::SemiAffordanceAccessor;
use MooseX::Types::Moose qw( Str );

has 'site' => (
    is => 'rw',
    isa => 'Pod::Site',
    weak_ref => 1,
);

sub view_pod {
    my ($self, $pod) = @_;
    return qq[<html>\n]
        . qq[<head>\n]
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
        
        my $uri = $self->site->uri ? $self->site->uri . '/' : '';
        $uri .= $loc . '.html';
        
        return qq[<a href="$uri">$text</a>\n];
    }
    
    $self->SUPER::view_seq_link( @_ );
}

1;
