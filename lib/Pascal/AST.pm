package Pascal::AST;

use v5.36;
use builtin qw(true false);

use Exporter 'import';

our @EXPORT_OK = qw(TYPE_UNKNOWN TYPE_PROGRAM_DECLARATION
    TYPE_VARIABLE_DECLARATION TYPE_VARIABLE_DECLARATION_BLOCK);
our %EXPORT_TAGS = ( constants => \@EXPORT_OK );


use constant {
    TYPE_UNKNOWN                    => 'unknown',
    TYPE_PROGRAM_DECLARATION        => 'program_declaration',
    TYPE_VARIABLE_DECLARATION       => 'variable_declaration',
    TYPE_VARIABLE_DECLARATION_BLOCK => 'variable_declaration_block',
};

use constant {
    TYPE        => 'type',
    TOKENS      => 'tokens',
    INDEX       => 'index',
};


sub new($class) {
    my $self = {};
    set_type($self, TYPE_UNKNOWN);
    $self->{TOKENS} = ();
    $self->{INDEX} = 0;
    bless $self, $class;
}

sub is_statement($self) {
    true;
}

sub type($self) {
    $self->{TYPE};
}

sub set_type($self, $type) {
    $self->{TYPE} = $type;
}

sub add_token($self, $token) {
    push @{$self->{TOKENS}}, $token;
}

sub has_next($self) {
    my $i = $self->{INDEX};
    my $len = scalar @{$self->{TOKENS}};
    $i < $len;
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

sub rewind($self) {
    $self->{INDEX} = 0;
}

sub format($self) {
    my $s = '[' . $self->type() . '] ';
    my $len = scalar @{$self->{TOKENS}};

    for (my $i = 0; $i < $len; $i++) {
        my $t = @{$self->{TOKENS}}[$i];
        $s = $s . $t->format();

        if ($i < $len - 1) {
            $s = $s . ' ';
        }
    }
    $s;
}

1;