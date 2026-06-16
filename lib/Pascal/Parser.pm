package Pascal::Parser;
use parent 'Parser';

use v5.36;

use Pascal::AST;
use Pascal::BlockAST;
use Pascal::AST::Identifier;
use Pascal::AST::Declaration;
use Pascal::AST::Variable;
use Pascal::AST::Type;
use Pascal::AST::VariableDeclaration;
use Pascal::AST::VariableDeclarationExpression;
use Pascal::AST::VariableDeclarationStatement;
use Pascal::AST::VariableDeclarationBlock;


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
            $self->add_ast($self->parse_variable_block($lexer));
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

sub parse_variable_block($self, $lexer) {
    my $block = Pascal::AST::VariableDeclarationBlock->new();

    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_newline()) {
            # Discard it.
            $lexer->next();

            # Pascal blocks usually span multiple lines.
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
            my $var = Pascal::AST::VariableDeclaration->new();

            $block->add_child($var);

            $lexer->next();
        }
        elsif ($peek->is_identifier()) {
            $block->add_child(parse_variable_declaration_statement($self, $lexer));
        }
        else {
            # Discard anything else.
            # There may be some edge cases here.
            $lexer->next();
        }
    }

    $block;
}

sub parse_variable_declaration_statement($self, $lexer) {
    my $stmt = Pascal::AST::VariableDeclarationStatement->new();

    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_newline()) {
            # Discard the token.
            $lexer->next();

            # Some Pascal statements span multiple lines.
            next;
        }

        if ($peek->is_statement()) {
            my $ast = Pascal::AST::Statement->new();
            $ast->add_child($peek);

            $stmt->add_child($ast);

            $lexer->next();

            # A statement stop here.
            last;
        }

        if ($peek->is_identifier()) {
            my $expr = $self->parse_variable_declaration_expression($lexer);

            $stmt->add_child($expr);
        }
        else {
            # Discard anything else.
            $lexer->next();
        }
    }

    $stmt;
}

sub parse_variable_declaration_expression($self, $lexer) {
    my $expr = Pascal::AST::VariableDeclarationExpression->new();

    while ($lexer->has_next()) {
        my $peek = $lexer->peek();

        if ($peek->is_newline()) {
            # Discard it.
            $lexer->next();

            # Some Pascal statements span multiple lines.
            next;
        }

        if ($peek->is_identifier()) {
            my $var = Pascal::AST::Variable->new();
            $var->add_child($peek);

            $expr->add_child($var);

            $lexer->next();
        }
        elsif ($peek->is_declaration()) {
            my $declaration = Pascal::AST::Declaration->new();
            $declaration->add_child($peek);

            $expr->add_child($declaration);

            $lexer->next();
            $peek = $lexer->peek();

            if ($peek->is_identifier() or $peek->is_keyword()) {
                my $t = Pascal::AST::Type->new();
                $t->add_child($peek);

                $expr->add_child($t);

                $lexer->next();
            }
        }
        else {
            last;
        }
    }

    $expr;
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