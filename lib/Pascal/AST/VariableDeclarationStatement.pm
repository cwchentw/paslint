package Pascal::AST::VariableDeclarationStatement;
use parent 'Pascal::AST::Statement';

use v5.36;
use builtin qw(true false);


sub new($class) {
    my $self = $class->SUPER::new();
    $self->set_type(Pascal::AST::Statement->TYPE_VARIABLE_DECLARATION_STATEMENT);
    bless $self, $class;
}

sub is_statement($self) {
    true;
}

1;
