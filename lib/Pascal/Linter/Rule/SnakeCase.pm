package Pascal::Linter::Rule::SnakeCase;

use v5.36;
use builtin qw(true false);

use Exporter 'import';

our @EXPORT = qw(is_snake_case);

use Pascal::Token;


sub is_snake_case($ast, $file_name) {
    if ($ast->is_statement()) {
        _is_snake_case($ast, $file_name);
        $ast->rewind();
    }
    else {
        while ($ast->has_next()) {
            is_snake_case($ast->next(), $file_name);
        }
        $ast->rewind();
    }
}

sub _is_snake_case($ast, $file_name) {
    while ($ast->has_next()) {
        my $t = $ast->next();

        if ($t->is_type(Pascal::Token->TYPE_IDENTIFIER)) {
            my $s = $t->content();

            if ($s =~ /_?[A-Za-z][A-Za-z0-9]*_[A-Za-z0-9]+/) {
                say 'Snake case ' . '[' . $file_name . '] '
                    . '(' . $t->line_number() . ',' . $t->column_number . ') '
                    . $s;
            }
        }
    }
}

1;