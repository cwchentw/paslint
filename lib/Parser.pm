package Parser;

use v5.36;


use constant {
    ASTS  => 'asts',
    INDEX => 'index',
};


sub new($class) {
    my $self = {};
    $self->{ASTS} = [];
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

1;
