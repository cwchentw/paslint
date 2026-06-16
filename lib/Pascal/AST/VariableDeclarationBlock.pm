package Pascal::AST::VariableDeclarationBlock;
use parent 'Pascal::BlockAST';

use v5.36;


sub new($class) {
    my $self = $class->SUPER::new();
    $self->set_type(Pascal::BlockAST->TYPE_VARIABLE_DECLARATION_BLOCK);
    bless $self, $class;
}

1;
