package Pascal::Lexer;

use v5.36;

use Pascal::Token;

# Pascal mode for keywords and modifiers.
use constant {
    MODE_FPC    => 1 << 0,                  # 0001
    MODE_DELPHI => 1 << 1,                  # 0010
};

use constant {
    MODE_RELAX  => MODE_FPC | MODE_DELPHI,  # 0011
};

use constant {
    PROGRAM_KEYWORDS         => 'keywords',
    PROGRAM_SYMBOLS          => 'symbols',
    PROGRAM_COMPOUND_SYMBOLS => 'compound_symbols',
};

use constant {
    LEXER_TOKENS => 'tokens',
    LEXER_INDEX  => 'index',
};

our $PROGRAM = {};

sub new($class) {
    my $self = {};
    $self->{LEXER_TOKENS} = ();
    $self->{LEXER_INDEX} = 0;
    bless $self, $class;
}

sub has_next($self) {
    my $index = $self->{LEXER_INDEX};
    my $len = scalar @{$self->{LEXER_TOKENS}};
    $index < $len;
}

sub next($self) {
    my $i = $self->{LEXER_INDEX};
    my $t = @{$self->{LEXER_TOKENS}}[$i];
    ($self->{LEXER_INDEX})++;
    $t;
}

sub peek($self) {
    my $i = $self->{LEXER_INDEX};
    my $t = @{$self->{LEXER_TOKENS}}[$i];
    $t;
}

sub lex($self, $s, $l) {
    my $i = 0;
    my $len = length($s);

    while ($i < $len) {
        my $peek = substr($s, $i, 1);
        my $j = $i;

        if (is_space($peek)) {
            while ($j < $len && is_space(substr($s, $j, 1))) {
                $j++;
            }

            # Discard space(s).

            $i = $j;
        }
        elsif (is_declaration($peek)) {
            my $t = Pascal::Token->new();

            if (is_assignment(substr($s, $j, 2))) {
                $j = $j + 2;

                $t->set_type(Pascal::Token->TOKEN_TYPE_ASSIGNMENT);
            }
            else {
                $j++;

                $t->set_type(Pascal::Token->TOKEN_TYPE_DECLARATION);
            }

            $t->set_content(substr($s, $i, $j - $i));

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_equality($peek)) {
            my $t = Pascal::Token->new();

            $t->set_type(Pascal::Token->TOKEN_TYPE_EQUALITY);
            $t->set_content($peek);

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            $j++;

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_statement($peek)) {
            my $t = Pascal::Token->new();

            $t->set_type(Pascal::Token->TOKEN_TYPE_STATEMENT);
            $t->set_content($peek);

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            $j++;

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_symbol($peek)) {
            my $t = Pascal::Token->new();

            my $sym;
            if (is_compound_symbol(substr($s, $j, 2))) {
                $sym = substr($s, $j, 2);

                $j = $j + 2;
            }
            else {
                $sym = $peek;

                $j++;
            }

            $t->set_type(Pascal::Token->TOKEN_TYPE_SYMBOL);
            $t->set_content($sym);

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_idenfitier_prefix($peek)) {
            my $t = Pascal::Token->new();

            while ($j < $len && is_identifier(substr($s, $j, 1))) {
                $j++;
            }

            my $word = substr($s, $i, $j - $i);
            if (is_keyword($word)) {
                $t->set_type(Pascal::Token->TOKEN_TYPE_KEYWORD);
            } else {
                $t->set_type(Pascal::Token->TOKEN_TYPE_IDENTIFIER);
            }

            $t->set_content($word);

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_newline($peek)) {
            my $t = Pascal::Token->new();

            $t->set_type(Pascal::Token->TOKEN_TYPE_NEWLINE);
            $t->set_content($peek);

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            $j++;

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_code($peek)) {
            my $t = Pascal::Token->new();

            while ($j < $len && is_code(substr($s, $j, 1))) {
                $j++;
            }

            $t->set_type(Pascal::Token->TOKEN_TYPE_CODE);
            $t->set_content(substr($s, $i, $j - $i));

            $t->set_line_number($l);
            $t->set_column_number($i + 1);

            push @{$self->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        else {
            # Discard anything else.
            # There may be some edge here.

            $j++;

            $i = $j;
        }
    }
}


sub is_keyword($k) {
    ${$PROGRAM->{PROGRAM_KEYWORDS}}{lc($k)};
}

sub is_symbol($s) {
    ${$PROGRAM->{PROGRAM_SYMBOLS}}{$s};
}

sub is_compound_symbol($s) {
    ${$PROGRAM->{PROGRAM_COMPOUND_SYMBOLS}}{$s};
}

sub is_idenfitier_prefix($s) {
    $s =~ /[A-Za-z_]/;
}

sub is_identifier($s) {
    $s =~ /[A-Za-z0-9_]/;
}

sub is_snake_case($s) {
    $s =~ /_?[A-Za-z][A-Za-z0-9]*_[A-Za-z0-9]+/;
}

sub is_space($s) {
    $s =~ /[ \t]/;
}

sub is_declaration($s) {
    $s eq ':';
}

sub is_assignment($s) {
    $s eq ':=';
}

sub is_equality($s) {
    $s eq '=';
}

sub is_statement($s) {
    $s eq ';';
}

sub is_newline($s) {
    $s eq "\n";
}

sub is_code($s) {
    ((not is_identifier($s)) and (not is_space($s))
        and (not is_newline($s)) and (not is_symbol($s))); 
}

sub init($config = {}) {
    if (defined $config && eval { $config->isa(__PACKAGE__) }) {
        die "init() is a utility function";
    }

    # Simply ignore $config for now.

    # TODO: Set Pascal mode.
    %{$PROGRAM->{PROGRAM_KEYWORDS}}         = pascal_keywords();
    %{$PROGRAM->{PROGRAM_SYMBOLS}}          = pascal_symbols();
    %{$PROGRAM->{PROGRAM_COMPOUND_SYMBOLS}} = pascal_compound_symbols();
}

sub pascal_keywords($mode = MODE_RELAX) {
    # Free Pascal 3.2.2
    my @turboPascalKeywords = ('absolute', 'and', 'array', 'asm', 'begin',
        'case', 'const', 'constructor', 'destructor', 'div', 'do', 'downto',
        'else', 'end', 'file', 'for', 'function', 'goto', 'if',
        'implementation', 'in', 'inherited', 'inline', 'interface', 'label',
        'mod', 'nil', 'not', 'object', 'of', 'operator', 'or', 'packed',
        'procedure', 'program', 'record', 'reintroduce', 'repeat', 'self',
        'set', 'shl', 'shr', 'string', 'then', 'to', 'type', 'unit', 'until',
        'uses', 'var', 'while', 'with', 'xor');
    # Free Pascal 3.2.2
    my @objectPascalKeywords = ('as', 'class', 'dispinterface', 'except',
        'exports', 'finalization', 'finally', 'initialization', 'inline',
        'is', 'library', 'on', 'out', 'packed', 'property', 'raise',
        'resourcestring', 'threadvar', 'try');
    # Delphi 13.1
    my @delphiKeywords = ('and', 'end', 'interface', 'record', 'var', 'array',
        'except', 'is', 'repeat', 'while', 'as', 'exports', 'label',
        'resourcestring', 'with', 'asm', 'file', 'library', 'set', 'xor',
        'begin', 'finalization', 'mod', 'shl', 'case', 'finally', 'nil',
        'shr', 'class', 'for', 'not', 'string', 'const', 'function', 'object',
        'then', 'constructor', 'goto', 'of', 'threadvar', 'destructor', 'if',
        'or', 'to', 'dispinterface', 'implementation', 'packed', 'try', 'div',
        'in', 'procedure', 'type', 'do', 'inherited', 'program', 'unit',
        'downto', 'initialization', 'property', 'until', 'else', 'inline',
        'raise', 'uses');

    my %ks = ();

    if ($mode & MODE_FPC) {
        for my $k (@turboPascalKeywords) {
            $ks{$k} = 1;  # True
        }

        for my $k (@objectPascalKeywords) {
            $ks{$k} = 1;  # True
        }
    }

    if ($mode & MODE_DELPHI) {
        for my $k (@delphiKeywords) {
            $ks{$k} = 1;  # True
        }
    }

    %ks;
}

sub pascal_symbols($mode = MODE_RELAX) {
    # Free Pascal 3.2.2
    my @freePascalSymbols = (
        "'", '+', '-', '*',  '/', '=', '<', '>', '[', ']', '.', ',', '(', ')',
        ':', '^',  '@', '{', '}', '$', '#', '&', '%'
    );
    # Delphi 13.1
    my @delphiSymbols = (
        '#', '$', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/', ':', ';',
        '<', '=', '>', '@', '[', ']', '^', '{', '}'
    );

    my %ss = ();

    if ($mode & MODE_FPC) {
        for my $s (@freePascalSymbols) {
            $ss{$s} = 1;  # True
        }
    }

    if ($mode & MODE_DELPHI) {
        for my $s (@delphiSymbols) {
            $ss{$s} = 1;  # True
        }
    }

    %ss;
}

sub pascal_compound_symbols($mode = MODE_RELAX) {
    # Free Pascal 3.2.2
    my @freePascalSymbols = (
        '<<', '>>', '**', '<>', '><', '<=', '>=', ':=', '+=', '-=', '*=', '/=',
        '(*', '*)', '(.', '.)', '//'
    );
    # Delphi 13.1
    my @delphiSymbols = (
        '(*', '(.', '*)', '.)', '..', '//', ':=', '<=', '>=', '<>'
    );

    my %ss = ();

    if ($mode & MODE_FPC) {
        for my $s (@freePascalSymbols) {
            $ss{$s} = 1;  # True
        }
    }

    if ($mode & MODE_DELPHI) {
        for my $s (@delphiSymbols) {
            $ss{$s} = 1;  # True
        }
    }

    %ss;
}

1;