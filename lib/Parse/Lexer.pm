package Parse::Lexer;

use v5.36;


use constant {
    TOKENS => 'tokens',
    INDEX => 'index',
};


sub new($class) {
    my $self = {};
    $self->{TOKENS} = [];
    $self->{INDEX} = 0;
    bless $self, $class;
}

sub add_token($self, $t) {
    push @{$self->{TOKENS}}, $t;
}

sub has_next($self) {
    my $index = $self->{INDEX};
    my $len = scalar @{$self->{TOKENS}};
    $index < $len;
}

sub next($self) {
    my $i = $self->{INDEX};
    my $t = @{$self->{TOKENS}}[$i];
    ($self->{INDEX})++;
    $t;
}

sub peek($self) {
    my $i = $self->{INDEX};
    my $t = @{$self->{TOKENS}}[$i];
    $t;
}

1;
