package Pascal::Lexer;

use v5.36;

use Exporter 'import';

our @EXPORT = qw(lexer_create lexer_has_next lexer_next lexer_peek lexer_lex init $PROGRAM);

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

sub lexer_create() {
    my $lexer = {};
    $lexer->{LEXER_TOKENS} = ();
    $lexer->{LEXER_INDEX} = 0;
    $lexer;
}

sub lexer_has_next($lexer) {
    my $index = $lexer->{LEXER_INDEX};
    my $len = scalar @{$lexer->{LEXER_TOKENS}};
    $index < $len;
}

sub lexer_next($lexer) {
    my $i = $lexer->{LEXER_INDEX};
    my $t = @{$lexer->{LEXER_TOKENS}}[$i];
    ($lexer->{LEXER_INDEX})++;
    $t;
}

sub lexer_peek($lexer) {
    my $i = $lexer->{LEXER_INDEX};
    my $t = @{$lexer->{LEXER_TOKENS}}[$i];
    $t;
}

sub lexer_lex($lexer, $s, $l) {
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
            my $t = token_create();

            if (is_assignment(substr($s, $j, 2))) {
                $j = $j + 2;

                token_set_type($t, TOKEN_TYPE_ASSIGNMENT);
            }
            else {
                $j++;

                token_set_type($t, TOKEN_TYPE_DECLARATION);
            }

            token_set_content($t, substr($s, $i, $j - $i));

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            push @{$lexer->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_equality($peek)) {
            my $t = token_create();

            token_set_type($t, TOKEN_TYPE_EQUALITY);
            token_set_content($t, $peek);

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            $j++;

            push @{$lexer->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_statement($peek)) {
            my $t = token_create();

            token_set_type($t, TOKEN_TYPE_STATEMENT);
            token_set_content($t, $peek);

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            $j++;

            push @{$lexer->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_symbol($peek)) {
            my $t = token_create();

            my $sym;
            if (is_compound_symbol(substr($s, $j, 2))) {
                $sym = substr($s, $j, 2);

                $j = $j + 2;
            }
            else {
                $sym = $peek;

                $j++;
            }

            token_set_type($t, TOKEN_TYPE_SYMBOL);
            token_set_content($t, $sym);

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            push @{$lexer->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_idenfitier_prefix($peek)) {
            my $t = token_create();

            while ($j < $len && is_identifier(substr($s, $j, 1))) {
                $j++;
            }

            my $word = substr($s, $i, $j - $i);
            if (is_keyword($word)) {
                token_set_type($t, TOKEN_TYPE_KEYWORD);
            } else {
                token_set_type($t, TOKEN_TYPE_IDENTIFIER);
            }

            token_set_content($t, $word);

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            push @{$lexer->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_newline($peek)) {
            my $t = token_create();

            token_set_type($t, TOKEN_TYPE_NEWLINE);
            token_set_content($t, $peek);

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            $j++;

            push @{$lexer->{LEXER_TOKENS}}, $t;

            $i = $j;
        }
        elsif (is_code($peek)) {
            my $t = token_create();

            while ($j < $len && is_code(substr($s, $j, 1))) {
                $j++;
            }

            token_set_type($t, TOKEN_TYPE_CODE);
            token_set_content($t, substr($s, $i, $j - $i));

            token_set_line_number($t, $l);
            token_set_column_number($t, $i + 1);

            push @{$lexer->{LEXER_TOKENS}}, $t;

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