package Parse::Token;

use v5.36;


use constant {
    TYPE    => 'type',
    CONTENT => 'content',
    LINE    => 'line',
    COLUMN  => 'column',
};

use constant {
    TYPE_UNKNOWN => 'unknown',
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

1;
