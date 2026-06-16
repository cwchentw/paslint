package Pascal::BlockAST;
use parent 'AST';

use v5.36;
use builtin qw(true false);


use constant {
    TYPE        => 'type',
    STATEMENTS  => 'statements',
    INDEX       => 'index',
};


sub new($class) {
    my $self = $class->SUPER::new();
    bless $self, $class;
}

sub is_statement($self) {
    false;
}

1;
