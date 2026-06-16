package Pascal::AST::Statement;
use parent 'Pascal::AST';

use v5.36;


use constant {
    TYPE_VARIABLE_DECLARATION_STATEMENT => 'variable_declaration_statement',
};


sub new($class) {
    my $self = $class->SUPER::new();
    $self->set_type(Pascal::AST->TYPE_STATEMENT);
    bless $self, $class;
}

1;
