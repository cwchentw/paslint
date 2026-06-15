package Pascal::Token;
use parent 'Token';

use v5.36;


use constant {
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
    my $self = $class->SUPER::new();
    bless $self, $class;
}

sub is_type($self, $type) {
    $self->type() eq $type;
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
        and ((lc($self->content()) eq 'begin')
            or (lc($self->content()) eq 'end'));
}

sub is_start_block($self) {
    is_type($self, TYPE_KEYWORD)
        and (lc($self->content()) eq 'begin');
}

sub is_end_block($self) {
    is_type($self, TYPE_KEYWORD)
        and (lc($self->content()) eq 'end');
}

sub is_variable_block($self) {
    is_type($self, TYPE_KEYWORD)
        and ((lc($self->content()) eq 'const')
            or (lc($self->content()) eq 'type')
            or (lc($self->content()) eq 'var'));
}

sub is_program_declaration($self) {
    is_type($self, TYPE_KEYWORD)
        and ((lc($self->content()) eq 'program')
            or (lc($self->content()) eq 'unit')
            or (lc($self->content()) eq 'library'));
}

1;
