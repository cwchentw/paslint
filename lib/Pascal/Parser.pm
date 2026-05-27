package Pascal::Parser;

use v5.36;

use Pascal::Token;
use Pascal::Lexer;
use Pascal::AST;


use constant {
    ASTS  => 'asts',
    INDEX => 'index',
};


sub new($class) {
    my $self = {};
    $self->{ASTS} = ();
    $self->{INDEX} = 0;
    bless $self, $class;
}

sub add_ast($self, $ast) {
    push @{$self->{ASTS}}, $ast;
}

sub has_next($self) {
    my $i = $self->{INDEX};
    my $len = scalar @{$self->{ASTS}};
    $i < $len;
}

sub next($self) {
    my $i = $self->{INDEX};
    my $ast = @{$self->{ASTS}}[$i];
    ($self->{INDEX})++;
    $ast;
}

sub peek($self) {
    my $i = $self->{INDEX};
    my $ast = @{$self->{ASTS}}[$i];
    $ast;
}

sub parse($self, $lexer) {
    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_program_declaration()) {
            add_ast($self,
                parse_statement($self, $lexer));
        }
        elsif ($peek->is_variable_block()) {
            add_ast($self,
                parse_variable_block($self, $lexer));
        }

        # Discard anything else.
        $lexer->next();
    }
}

sub parse_variable_block($self, $lexer) {
    my $ast = block_ast_create();

    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_newline()) {
            # Discard the token.
            $lexer->next();

            # Some Pascal statements span multiple lines.
            next;
        }

        if ($peek->is_declaration()) {
            # The block ends.
            last;
        }

        if ($peek->is_block()) {
            # The block ends.
            last;
        }

        if ($peek->is_variable_block()) {
            block_ast_set_type($ast,
                AST_TYPE_VARIABLE_DECLARATION_BLOCK);
            # Discard the token.
            $lexer->next();
        }
        elsif ($peek->is_identifier()) {
            block_ast_add_statement($ast,
                parse_statement($self, $lexer));
        }
        else {
            # Discard anything else.
            # There may be some edge cases here.
        }

        $lexer->next();
    }

    $ast;
}

sub parse_statement($self, $lexer) {
    my $ast = ast_create();

    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_newline()) {
            # Discard the token.
            $lexer->next();

            # Some Pascal statements span multiple lines.
            next;
        }

        if ($peek->is_statement()) {
            # Discard the token.
            $lexer->next();

            # A statement stop here.
            last;
        }

        my $token = $lexer->next();

        if ($token->is_program_declaration()) {
            ast_set_type($ast, AST_TYPE_PROGRAM_DECLARATION);
        }
        elsif ($token->is_identifier()) {
            if (($lexer->peek())->is_declaration()) {
                ast_set_type($ast, AST_TYPE_VARIABLE_DECLARATION);
            }
        }

        ast_add_tokens($ast, $token);
    }

    $ast;
}

1;