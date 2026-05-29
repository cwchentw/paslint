package Pascal::Linter::Rule::LongLine;

use v5.36;
use builtin qw(true false);

use Exporter 'import';

our @EXPORT = qw(is_long_line);

use Pascal::Token;


sub is_long_line($ast, $file_name) {
    if ($ast->is_statement()) {
        _is_long_line($ast, $file_name);
        $ast->rewind();
    }
    else {
        while ($ast->has_next()) {
            is_long_line($ast->next(), $file_name);
        }
        $ast->rewind();
    }
}

sub _is_long_line($ast, $file_name) {
    while ($ast->has_next()) {
        my $t = $ast->next();
        if ($t->is_type(Pascal::Token->TYPE_NEWLINE)) {
            next;
        }

        if ($t->column_number() > 80) {
            say 'Long line: ' . '[' . $file_name . '] '
                . ' at line ' . $t->line_number();
        }
    }
}

1;