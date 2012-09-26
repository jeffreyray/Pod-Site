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
 	. $pod->content->present($self)
        . qq[</div>\n]
        . qq[</body>\n]
        . qq[</html>\n];
}


sub view_seq_link {
    my ($self, $link) = @_;
    
    if ( $link =~ /^</ ) {
	return "$link";
    }
    
    elsif ( $link =~ /(\w|:)+/ ) {
	
        my ($loc, $text) = ($link, $link);
        $loc =~ s/::/\\/g;
        
        my $path = $self->site->dir ? $self->site->dir . '\\' : '';
        $path .= $loc . '.html';
	
	
        if ( -e $path ) {
            my $uri = $self->site->uri ? $self->site->uri . '/' : '';
            $uri .= $loc . '.html';
            return qq[<a href="$uri">$text</a>\n];
        }
        else {
	    #print "not exist: $path\n";
            my $uri = qq[http://search.cpan.org/perldoc?$text];
            return qq[<a href="$uri">$text</a>\n];
        }
    }
    else {
        return $self->SUPER::view_seq_link( @_ );
    }
}

sub view_item {
    my ($self, $item) = @_;
    no warnings;
    my $over  = ref $self ? $self->{ OVER } : \@Pod::POM::View::HTML::OVER;
    my $title = $item->title();
    my $strip = $over->[-1];
    
    if (defined $title) {
        $title = $title->present($self) if ref $title;
        $title =~ s/$strip// if $strip;
        if (length $title) {
	    
            my $anchor = $title;
            $anchor =~ s/^\s*|\s*$//g; # strip leading and closing spaces
            $anchor =~ s/\W/_/g;
            $title = qq{<a name="item_$anchor"></a>$title};
        }
    }

    return '<li>'
        . "$title\n"
        . $item->content->present($self)
        . "</li>\n";
}



1;
