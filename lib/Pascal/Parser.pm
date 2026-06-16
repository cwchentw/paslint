package Pascal::Parser;
use parent 'Parser';

use v5.36;

use Pascal::AST;
use Pascal::BlockAST;


sub new($class) {
    my $self = $class->SUPER::new();
    bless $self, $class;
}

sub parse($self, $lexer) {
    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_program_declaration()) {
            $self->add_ast(parse_statement($self, $lexer));
        }
        elsif ($peek->is_variable_block()) {
            $self->add_ast(parse_value_block($self, $lexer));
        }
        elsif ($peek->is_start_block()) {
            $self->add_ast(parse_block($self, $lexer));
        }
        else {
            # Discard anything else.
            $lexer->next();
        }
    }
}

sub parse_block($self, $lexer) {
    my $ast = Pascal::BlockAST->new();

    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_newline()) {
            # Discard the token.
            $lexer->next();

            # Some Pascal statements span multiple lines.
            next;
        }

        if ($peek->is_start_block()) {
            $ast->set_type(Pascal::AST->TYPE_BLOCK);

            # Discard the token.
            $lexer->next();
        }
        elsif ($peek->is_end_block()) {
            # Discard the token.
            $lexer->next();

            last;
        }
        elsif ($peek->is_identifier()) {
            $ast->add_child(parse_statement($self, $lexer));
        }
        else {
            # Discard anything else.
            # There may be some edge cases here.
            $lexer->next();
        }
    }

    $ast;
}

sub parse_value_block($self, $lexer) {
    my $ast = Pascal::BlockAST->new();

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
            $ast->set_type(Pascal::AST->TYPE_VARIABLE_DECLARATION_BLOCK);
            # Discard the token.
            $lexer->next();
        }
        elsif ($peek->is_identifier()) {
            $ast->add_child(parse_statement($self, $lexer));
        }
        else {
            # Discard anything else.
            # There may be some edge cases here.
            $lexer->next();
        }
    }

    $ast;
}

sub parse_statement($self, $lexer) {
    # TODO: Refactor AST into granular Statement and Expression sub-nodes.
    my $ast = Pascal::AST->new();

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
            $ast->set_type(Pascal::AST->TYPE_PROGRAM_DECLARATION);
        }
        elsif ($token->is_identifier()) {
            if (($lexer->peek())->is_declaration()) {
                $ast->set_type(Pascal::AST->TYPE_VARIABLE_DECLARATION);
            }
            elsif (($lexer->peek())->is_assignment()) {
                $ast->set_type(Pascal::AST->TYPE_VARIABLE_ASSIGNMENT);
            }
        }

        $ast->add_child($token);
    }

    $ast;
}

1;