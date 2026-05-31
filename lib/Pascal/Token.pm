package Pascal::Token;

use v5.36;


use constant {
    TYPE    => 'type',
    CONTENT => 'content',
    LINE    => 'line',
    COLUMN  => 'column',
};

use constant {
    TYPE_UNKNOWN     => 'unknown',
    TYPE_SPACE       => 'space',
    TYPE_DECLARATION => 'declaration',
    TYPE_ASSIGNMENT  => 'assignment',
    TYPE_EQUALITY    => 'equality',
    TYPE_STATEMENT   => 'statement',
    TYPE_SYMBOL      => 'symbol',
    TYPE_KEYWORD     => 'keyword',
    TYPE_IDENTIFIER  => 'identifier',
    TYPE_NEWLINE     => 'newline',
    TYPE_CODE        => 'code',
};


sub new($class) {
    my $self = {};
    set_type($self, TYPE_UNKNOWN);
    set_content($self, '');
    set_line_number($self, 1);
    set_column_number($self, 1);
    bless $self, $class;
}

sub type($self) {
    $self->{TYPE};
}

sub set_type($self, $type) {
    $self->{TYPE} = $type;
}

sub content($self) {
    $self->{CONTENT};
}

sub set_content($self, $content) {
    $self->{CONTENT} = $content;
}

sub line_number($self) {
    $self->{LINE};
}

sub set_line_number($self, $n) {
    $self->{LINE} = $n;
}

sub column_number($self) {
    $self->{COLUMN};
}

sub set_column_number($self, $n) {
    $self->{COLUMN} = $n;
}

sub format($self) {
    "[" . $self->{TYPE} . "] "
    . "(" . $self->{LINE} . "," . $self->{COLUMN} . ") "
    . "<" . $self->{CONTENT} . ">";
}

sub is_type($self, $type) {
    type($self) eq $type;
}

sub is_declaration($self) {
    is_type($self, TYPE_DECLARATION);
}

sub is_assignment($self) {
    is_type($self, TYPE_ASSIGNMENT);
}

sub is_newline($self) {
    is_type($self, TYPE_NEWLINE);
}

sub is_statement($self) {
    is_type($self, TYPE_STATEMENT);
}

sub is_identifier($self) {
    is_type($self, TYPE_IDENTIFIER);
}

sub is_block($self) {
    is_type($self, TYPE_KEYWORD)
        and ((lc(content($self)) eq 'begin')
            or (lc(content($self)) eq 'end'));
}

sub is_start_block($self) {
    is_type($self, TYPE_KEYWORD)
        and (lc(content($self)) eq 'begin');
}

sub is_end_block($self) {
    is_type($self, TYPE_KEYWORD)
        and (lc(content($self)) eq 'end');
}

sub is_variable_block($self) {
    is_type($self, TYPE_KEYWORD)
        and ((lc(content($self)) eq 'const')
            or (lc(content($self)) eq 'type')
            or (lc(content($self)) eq 'var'));
}

sub is_program_declaration($self) {
    is_type($self, TYPE_KEYWORD)
        and ((lc(content($self)) eq 'program')
            or (lc(content($self)) eq 'unit')
            or (lc(content($self)) eq 'library'));
}

1;