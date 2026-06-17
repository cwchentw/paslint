package Pascal::BlockAST;
use parent 'Parse::AST';

use v5.36;
use builtin qw(true false);


use constant {
    TYPE        => 'type',
    STATEMENTS  => 'statements',
    INDEX       => 'index',
};

use constant {
    TYPE_VARIABLE_DECLARATION_BLOCK => 'variable_declaration_block',
};


sub new($class) {
    my $self = $class->SUPER::new();
    bless $self, $class;
}

sub is_statement($self) {
    false;
}

1;
