package Pascal::AST::VariableDeclaration;
use parent 'Pascal::AST';

use v5.36;

sub new($class) {
    my $self = $class->SUPER::new();
    $self->set_type(Pascal::AST->TYPE_VARIABLE_DECLARATION);
    bless $self, $class;
}

1;
