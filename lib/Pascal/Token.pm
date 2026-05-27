package Pascal::Token;

use v5.36;


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


sub new($class) {
    my $self = {};
    set_type($self, TOKEN_TYPE_UNKNOWN);
    set_content($self, '');
    set_line_number($self, 1);
    set_column_number($self, 1);
    bless $self, $class;
}

sub type($self) {
    $self->{TOKEN_TYPE};
}

sub set_type($self, $type) {
    $self->{TOKEN_TYPE} = $type;
}

sub content($self) {
    $self->{TOKEN_CONTENT};
}

sub set_content($self, $content) {
    $self->{TOKEN_CONTENT} = $content;
}

sub line_number($self) {
    $self->{TOKEN_LINE};
}

sub set_line_number($self, $n) {
    $self->{TOKEN_LINE} = $n;
}

sub column_number($self) {
    $self->{TOKEN_COLUMN};
}

sub set_column_number($self, $n) {
    $self->{TOKEN_COLUMN} = $n;
}

sub format($self) {
    "[" . $self->{TOKEN_TYPE} . "] "
    . "(" . $self->{TOKEN_LINE} . "," . $self->{TOKEN_COLUMN} . ") "
    . "<" . $self->{TOKEN_CONTENT} . ">";
}

sub is_type($self, $type) {
    type($self) eq $type;
}

sub is_declaration($self) {
    is_type($self, TOKEN_TYPE_DECLARATION);
}

sub is_newline($self) {
    is_type($self, TOKEN_TYPE_NEWLINE);
}

sub is_statement($self) {
    is_type($self, TOKEN_TYPE_STATEMENT);
}

sub is_identifier($self) {
    is_type($self, TOKEN_TYPE_IDENTIFIER);
}

sub is_block($self) {
    is_type($self, TOKEN_TYPE_KEYWORD)
        and ((lc(content($self)) eq 'begin')
            or (lc(content($self)) eq 'end'));
}

sub is_variable_block($self) {
    is_type($self, TOKEN_TYPE_KEYWORD)
        and ((lc(content($self)) eq 'const')
            or (lc(content($self)) eq 'type')
            or (lc(content($self)) eq 'var'));
}

sub is_program_declaration($self) {
    is_type($self, TOKEN_TYPE_KEYWORD)
        and ((lc(content($self)) eq 'program')
            or (lc(content($self)) eq 'unit')
            or (lc(content($self)) eq 'library'));
}

1;