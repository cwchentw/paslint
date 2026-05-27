package Pascal::AST;

use v5.36;

use Exporter 'import';

our @EXPORT = qw(block_ast_create block_ast_type block_ast_set_type
    block_ast_set_type block_ast_add_statement block_ast_has_next
    block_ast_next block_ast_peek ast_create ast_type ast_set_type
    ast_add_tokens ast_has_next ast_next ast_peek ast_format
    AST_TYPE_UNKNOWN AST_TYPE_PROGRAM_DECLARATION
    AST_TYPE_VARIABLE_DECLARATION AST_TYPE_VARIABLE_DECLARATION_BLOCK);

use Pascal::Token;


use constant {
    AST_TYPE_UNKNOWN                    => 'unknown',
    AST_TYPE_PROGRAM_DECLARATION        => 'program_declaration',
    AST_TYPE_VARIABLE_DECLARATION       => 'variable_declaration',
    AST_TYPE_VARIABLE_DECLARATION_BLOCK => 'variable_declaration_block',
};

use constant {
    AST_TYPE        => 'type',
    AST_TOKENS      => 'tokens',
    AST_STATEMENTS  => 'statements',
    AST_INDEX       => 'index',
};


# The block ast object.
sub block_ast_create() {
    my $ast = {};
    block_ast_set_type($ast, AST_TYPE_UNKNOWN);
    $ast->{AST_STATEMENTS} = ();
    $ast->{AST_INDEX} = 0;
    $ast;
}

sub block_ast_type($ast) {
    $ast->{AST_TYPE};
}

sub block_ast_set_type($ast, $type) {
    $ast->{AST_TYPE} = $type;
}

sub block_ast_add_statement($ast, $stmt) {
    push @{$ast->{AST_STATEMENTS}}, $stmt;
}

sub block_ast_has_next($ast) {
    my $i = $ast->{AST_INDEX};
    my $len = scalar @{$ast->{AST_STATEMENTS}};
    $i < $len;
}

sub block_ast_next($ast) {
    my $i = $ast->{AST_INDEX};
    my $t = @{$ast->{AST_STATEMENTS}}[$i];
    ($ast->{AST_INDEX})++;
    $t;
}

sub block_ast_peek($ast) {
    my $i = $ast->{AST_INDEX};
    my $t = @{$ast->{AST_STATEMENTS}}[$i];
    $t;
}

sub block_ast_format($ast) {
    my $s = '[' . ast_type($ast) . ']' . "\n";
    my $len = scalar @{$ast->{AST_STATEMENTS}};
    for (my $i = 0; $i < $len; $i++) {
        $s = $s . ast_format(@{$ast->{AST_STATEMENTS}}[$i]);

        if ($i < $len - 1) {
            $s = $s . "\n";
        }
    }
    $s;
}
# End of the block ast object.


# The ast object.
sub ast_create() {
    my $ast = {};
    ast_set_type($ast, AST_TYPE_UNKNOWN);
    $ast->{AST_TOKENS} = ();
    $ast->{AST_INDEX} = 0;
    $ast;
}

sub ast_type($ast) {
    $ast->{AST_TYPE};
}

sub ast_set_type($ast, $type) {
    $ast->{AST_TYPE} = $type;
}

sub ast_add_tokens($ast, $token) {
    push @{$ast->{AST_TOKENS}}, $token;
}

sub ast_has_next($ast) {
    my $i = $ast->{AST_INDEX};
    my $len = scalar @{$ast->{AST_TOKENS}};
    $i < $len;
}

sub ast_next($ast) {
    my $i = $ast->{AST_INDEX};
    my $t = @{$ast->{AST_TOKENS}}[$i];
    ($ast->{AST_INDEX})++;
    $t;
}

sub ast_peek($ast) {
    my $i = $ast->{AST_INDEX};
    my $t = @{$ast->{AST_TOKENS}}[$i];
    $t;
}

sub ast_format($ast) {
    if (exists $ast->{AST_STATEMENTS}) {
        block_ast_format($ast);
    }
    else {
        _ast_format($ast);
    }
}

sub _ast_format($ast) {
    my $s = '[' . ast_type($ast) . '] ';
    while (ast_has_next($ast)) {
        my $t = ast_next($ast);
        $s = $s . $t->format() . ' ';
    }
    $s;
}

1;