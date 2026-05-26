package Pascal::Parser;

use v5.36;

use Exporter 'import';

our @EXPORT = qw(parser_create parser_add_ast parser_has_next parser_next
    parser_peek parser_parse);

use Pascal::Token;
use Pascal::Lexer;
use Pascal::AST;


use constant {
    PARSER_ASTS  => 'asts',
    PARSER_INDEX => 'index',
};


sub parser_create() {
    my $parser = {};
    $parser->{PARSER_ASTS} = ();
    $parser->{PARSER_INDEX} = 0;
    $parser;
}

sub parser_add_ast($parser, $ast) {
    push @{$parser->{PARSER_ASTS}}, $ast;
}

sub parser_has_next($parser) {
    my $i = $parser->{PARSER_INDEX};
    my $len = scalar @{$parser->{PARSER_ASTS}};
    $i < $len;
}

sub parser_next($parser) {
    my $i = $parser->{PARSER_INDEX};
    my $ast = @{$parser->{PARSER_ASTS}}[$i];
    ($parser->{PARSER_INDEX})++;
    $ast;
}

sub parser_peek($parser) {
    my $i = $parser->{PARSER_INDEX};
    my $ast = @{$parser->{PARSER_ASTS}}[$i];
    $ast;
}

sub parser_parse($parser, $lexer) {
    while (lexer_has_next($lexer)) {
        my $peek = lexer_peek($lexer);

        if (is_program_declaration_token($peek)) {
            parser_add_ast($parser,
                parser_parse_statement($parser, $lexer));
        }
        elsif (is_variable_block_token($peek)) {
            parser_add_ast($parser,
                parser_parse_variable_block($parser, $lexer));
        }

        # Discard anything else.
        lexer_next($lexer);
    }
}

sub parser_parse_variable_block($parser, $lexer) {
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
                parser_parse_statement($parser, $lexer));
        }
        else {
            # Discard anything else.
            # There may be some edge cases here.
        }

        lexer_next($lexer);
    }

    $ast;
}

sub parser_parse_statement($parser, $lexer) {
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