package Pascal::BlockAST;

use v5.36;

use Pascal::Token;
use Pascal::AST qw(:constants);


use constant {
    TYPE        => 'type',
    STATEMENTS  => 'statements',
    INDEX       => 'index',
};


sub new($class) {
    my $self = {};
    set_type($self, TYPE_UNKNOWN);
    $self->{STATEMENTS} = ();
    $self->{INDEX} = 0;
    bless $self, $class;
}

sub type($self) {
    $self->{TYPE};
}

sub set_type($self, $type) {
    $self->{TYPE} = $type;
}

sub add_statement($self, $stmt) {
    push @{$self->{STATEMENTS}}, $stmt;
}

sub has_next($self) {
    my $i = $self->{INDEX};
    my $len = scalar @{$self->{STATEMENTS}};
    $i < $len;
}

sub next($self) {
    my $i = $self->{INDEX};
    my $t = @{$self->{STATEMENTS}}[$i];
    ($self->{INDEX})++;
    $t;
}

sub peek($self) {
    my $i = $self->{INDEX};
    my $t = @{$self->{STATEMENTS}}[$i];
    $t;
}

sub format($self) {
    my $s = '[' . $self->type() . ']' . "\n";
    my $len = scalar @{$self->{STATEMENTS}};
    for (my $i = 0; $i < $len; $i++) {
        my $ast = @{$self->{STATEMENTS}}[$i];
        $s = $s . $ast->format();

        if ($i < $len - 1) {
            $s = $s . "\n";
        }
    }
    $s;
}

1;