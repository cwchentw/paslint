package Pascal::Linter;

use v5.36;

use Pascal::Linter::Rule::LongLine;
use Pascal::Linter::Rule::SnakeCase;


use constant {
    RULE_LONG_LINE  => 1 << 0,  # 0001
    RULE_SNAKE_CASE => 1 << 1,  # 0010
};

use constant {
    ALL_RULES => RULE_LONG_LINE | RULE_SNAKE_CASE,
};

use constant {
    RULES => 'rules',
    INDEX => 'index',
};


sub new($class, $config = ALL_RULES) {
    my $self = {};

    $self->{RULES} = [];
    $self->{INDEX} = 0;

    add_rule($self, $config);

    bless $self, $class;
}

sub add_rule($self, $config) {
    if ($config & RULE_LONG_LINE) {
        push @{$self->{RULES}}, \&is_long_line;
    }

    if ($config & RULE_SNAKE_CASE) {
        push @{$self->{RULES}}, \&is_snake_case;
    }
}

sub lint($self, $parser, $file_name) {
    while ($parser->has_next()) {
        my $ast = $parser->next();

        # TODO: Only show AST in Debug mode.
        say $ast->format();

        for my $rule (@{$self->{RULES}}) {
            $rule->($ast, $file_name);
        }
    }
}


1;