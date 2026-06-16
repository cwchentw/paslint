package Pascal::AST;
use parent 'AST';

use v5.36;
use builtin qw(true false);


use constant {
    TYPE_BLOCK                      => 'block',
    TYPE_PROGRAM_DECLARATION        => 'program_declaration',
    TYPE_VARIABLE_ASSIGNMENT        => 'variable_assignment',
    TYPE_VARIABLE_DECLARATION       => 'variable_declaration',
    TYPE_VARIABLE_DECLARATION_BLOCK => 'variable_declaration_block',
};


sub new($class) {
    my $self = $class->SUPER::new();
    bless $self, $class;
}

# FIXME: Pascal::AST should not be a statement AST.
sub is_statement($self) {
    true;
}

1;
