package Pascal::AST::Type;
use parent 'Pascal::AST';

use v5.36;


sub new($class) {
    my $self = $class->SUPER::new();
    $self->set_type(Pascal::AST->TYPE_TYPE);
    bless $self, $class;
}

1;
