package Pascal::AST;
use parent 'AST';

use v5.36;
use builtin qw(true false);


use constant {
    TYPE_BLOCK     => 'block',
    TYPE_STATEMENT => 'statement',

    TYPE_DECLARATION => 'declaration',
    TYPE_VARIABLE    => 'variable',
    TYPE_IDENTIFIER  => 'identifier',
    TYPE_TYPE        => 'type',

    TYPE_VARIABLE_DECLARATION_EXPRESSION => 'variable_declaration_expression',

    TYPE_PROGRAM_DECLARATION => 'program_declaration',
    
    TYPE_VARIABLE_DECLARATION  => 'variable_declaration',
    TYPE_VARIABLE_ASSIGNMENT   => 'variable_assignment',
};


sub new($class) {
    my $self = $class->SUPER::new();
    bless $self, $class;
}

sub is_statement($self) {
    true;
}

1;
