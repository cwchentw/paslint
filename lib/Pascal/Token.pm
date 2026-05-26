package Pascal::Token;

use feature ':5.36';

use Exporter 'import';

our @EXPORT = qw(token_create token_type token_set_type token_content
    token_set_content token_line_number token_set_line_number
    token_column_number token_set_column_number token_format
    is_token_type is_declaration_token is_newline_token
    is_statement_token is_identifier_token is_block_token
    is_variable_block_token is_program_declaration_token
    TOKEN_TYPE_UNKNOWN TOKEN_TYPE_SPACE TOKEN_TYPE_DECLARATION
    TOKEN_TYPE_ASSIGNMENT TOKEN_TYPE_EQUALITY TOKEN_TYPE_STATEMENT
    TOKEN_TYPE_SYMBOL TOKEN_TYPE_KEYWORD TOKEN_TYPE_IDENTIFIER
    TOKEN_TYPE_NEWLINE TOKEN_TYPE_CODE);


use constant {
    TOKEN_TYPE    => 'type',
    TOKEN_CONTENT => 'content',
    TOKEN_LINE    => 'line',
    TOKEN_COLUMN  => 'column',
};

use constant {
    TOKEN_TYPE_UNKNOWN     => 'unknown',
    TOKEN_TYPE_SPACE       => 'space',
    TOKEN_TYPE_DECLARATION => 'declaration',
    TOKEN_TYPE_ASSIGNMENT  => 'assignment',
    TOKEN_TYPE_EQUALITY    => 'equality',
    TOKEN_TYPE_STATEMENT   => 'statement',
    TOKEN_TYPE_SYMBOL      => 'symbol',
    TOKEN_TYPE_KEYWORD     => 'keyword',
    TOKEN_TYPE_IDENTIFIER  => 'identifier',
    TOKEN_TYPE_NEWLINE     => 'newline',
    TOKEN_TYPE_CODE        => 'code',
};


sub token_create() {
    my $t = {};
    token_set_type($t, TOKEN_TYPE_UNKNOWN);
    token_set_content($t, '');
    token_set_line_number($t, 1);
    token_set_column_number($t, 1);
    $t;
}

sub token_type($token) {
    $token->{TOKEN_TYPE};
}

sub token_set_type($token, $type) {
    $token->{TOKEN_TYPE} = $type;
}

sub token_content($token) {
    $token->{TOKEN_CONTENT};
}

sub token_set_content($token, $content) {
    $token->{TOKEN_CONTENT} = $content;
}

sub token_line_number($token) {
    $token->{TOKEN_LINE};
}

sub token_set_line_number($token, $n) {
    $token->{TOKEN_LINE} = $n;
}

sub token_column_number($token) {
    $token->{TOKEN_COLUMN};
}

sub token_set_column_number($token, $n) {
    $token->{TOKEN_COLUMN} = $n;
}

sub token_format($t) {
    "[" . $t->{TOKEN_TYPE} . "] "
    . "(" . $t->{TOKEN_LINE} . "," . $t->{TOKEN_COLUMN} . ") "
    . "<" . $t->{TOKEN_CONTENT} . ">";
}

sub is_token_type($token, $type) {
    token_type($token) eq $type;
}

sub is_declaration_token($token) {
    is_token_type($token, TOKEN_TYPE_DECLARATION);
}

sub is_newline_token($token) {
    is_token_type($token, TOKEN_TYPE_NEWLINE);
}

sub is_statement_token($token) {
    is_token_type($token, TOKEN_TYPE_STATEMENT);
}

sub is_identifier_token($token) {
    is_token_type($token, TOKEN_TYPE_IDENTIFIER);
}

sub is_block_token($token) {
    is_token_type($token, TOKEN_TYPE_KEYWORD)
        and ((lc(token_content($token)) eq 'begin')
            or (lc(token_content($token)) eq 'end'));
}

sub is_variable_block_token($token) {
    is_token_type($token, TOKEN_TYPE_KEYWORD)
        and ((lc(token_content($token)) eq 'const')
            or (lc(token_content($token)) eq 'type')
            or (lc(token_content($token)) eq 'var'));
}

sub is_program_declaration_token($token) {
    is_token_type($token, TOKEN_TYPE_KEYWORD)
        and ((lc(token_content($token)) eq 'program')
            or (lc(token_content($token)) eq 'unit')
            or (lc(token_content($token)) eq 'library'));
}

1;