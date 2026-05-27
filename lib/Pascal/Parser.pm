package Pascal::Parser;

use v5.36;

use Pascal::Token;
use Pascal::Lexer;
use Pascal::AST;


use constant {
    PARSER_ASTS  => 'asts',
    PARSER_INDEX => 'index',
};


sub new($class) {
    my $self = {};
    $self->{PARSER_ASTS} = ();
    $self->{PARSER_INDEX} = 0;
    bless $self, $class;
}

sub add_ast($self, $ast) {
    push @{$self->{PARSER_ASTS}}, $ast;
}

sub has_next($self) {
    my $i = $self->{PARSER_INDEX};
    my $len = scalar @{$self->{PARSER_ASTS}};
    $i < $len;
}

sub next($self) {
    my $i = $self->{PARSER_INDEX};
    my $ast = @{$self->{PARSER_ASTS}}[$i];
    ($self->{PARSER_INDEX})++;
    $ast;
}

sub peek($self) {
    my $i = $self->{PARSER_INDEX};
    my $ast = @{$self->{PARSER_ASTS}}[$i];
    $ast;
}

sub parse($self, $lexer) {
    while (lexer_has_next($lexer)) {
        my $peek = lexer_peek($lexer);

        if (is_program_declaration_token($peek)) {
            add_ast($self,
                parse_statement($self, $lexer));
        }
        elsif (is_variable_block_token($peek)) {
            add_ast($self,
                parse_variable_block($self, $lexer));
        }

        # Discard anything else.
        lexer_next($lexer);
    }
}

sub parse_variable_block($self, $lexer) {
    my $ast = block_ast_create();

    while (lexer_has_next($lexer)) {
        my $peek = lexer_peek($lexer);

        if (is_newline_token($peek)) {
            # Discard the token.
            lexer_next($lexer);

            # Some Pascal statements span multiple lines.
            next;
        }

        if (is_declaration_token($peek)) {
            # The block ends.
            last;
        }

        if (is_block_token($peek)) {
            # The block ends.
            last;
        }

        if (is_variable_block_token($peek)) {
            block_ast_set_type($ast,
                AST_TYPE_VARIABLE_DECLARATION_BLOCK);
            # Discard the token.
            lexer_next($lexer);
        }
        elsif (is_identifier_token($peek)) {
            block_ast_add_statement($ast,
                parse_statement($self, $lexer));
        }
        else {
            # Discard anything else.
            # There may be some edge cases here.
        }

        lexer_next($lexer);
    }

    $ast;
}

sub parse_statement($self, $lexer) {
    my $ast = ast_create();

    while (lexer_has_next($lexer)) {
        my $peek = lexer_peek($lexer);

        if (is_newline_token($peek)) {
            # Discard the token.
            lexer_next($lexer);

            # Some Pascal statements span multiple lines.
            next;
        }

        if (is_statement_token($peek)) {
            # Discard the token.
            lexer_next($lexer);

            # A statement stop here.
            last;
        }

        my $token = lexer_next($lexer);

        if (is_program_declaration_token($token)) {
            ast_set_type($ast, AST_TYPE_PROGRAM_DECLARATION);
        }
        elsif (is_identifier_token($token)) {
            if (is_declaration_token(lexer_peek($lexer))) {
                ast_set_type($ast, AST_TYPE_VARIABLE_DECLARATION);
            }
        }

        ast_add_tokens($ast, $token);
    }

    $ast;
}

1;