package Pod::Site::Types;
use MooseX::Types -declare => [qw(
View 
)];

use MooseX::Types::Moose qw( Object Str );


subtype View,
    as Object;

coerce View,
    from Str,
    via { $_->new };

1;
