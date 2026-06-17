package Parse::AST;

use v5.36;


use constant {
    TYPE     => 'type',
    CHILDREN => 'children',
    INDEX    => 'index',
};

use constant {
    TYPE_UNKNOWN => 'unknown',
};


sub new($class) {
    my $self = {};
    set_type($self, TYPE_UNKNOWN);
    $self->{CHILDREN} = [];
    $self->{INDEX} = 0;
    bless $self, $class;
}

sub type($self) {
    $self->{TYPE};
}

sub set_type($self, $type) {
    $self->{TYPE} = $type;
}

sub add_child($self, $child) {
    push @{$self->{CHILDREN}}, $child;
}

sub has_next($self) {
    $self->{INDEX} < scalar @{$self->{CHILDREN}};
}

sub next($self) {
    my $c = $self->{CHILDREN}[$self->{INDEX}];
    $self->{INDEX}++;
    $c;
}

sub peek($self) {
    $self->{CHILDREN}[$self->{INDEX}];
}

sub rewind($self) {
    $self->{INDEX} = 0;
}

sub format($self) {
    my $s = '[' . $self->type() . '] ';
    my $len = scalar @{$self->{CHILDREN}};

    for (my $i = 0; $i < $len; $i++) {
        my $c = $self->{CHILDREN}[$i];
        if ($c->can('format')) {
            $s .= $c->format();
        } else {
            $s .= $c;
        }
        $s .= ' ' if $i < $len - 1;
    }

    $s;
}

1;
