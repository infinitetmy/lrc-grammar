lexer grammar LRCMixedLexer;

tokens {
    NEWLINE,
    TAG_OPEN, TAG_CLOSE, COLON, DOT,  // Structure
    ID_KEY, ID_VALUE,                 // ID Data
    TIME_NUM,                         // Time Data
    LYRICS_TEXT,                      // Content
    SPACE,
    SUB_TIME_TAG_OPEN, SUB_TIME_TAG_CLOSE
}

// ======================================================
// MODE: DEFAULT (ROOT)
// Entry point. Scans for the start of a line and detects 
// the initial opening bracket '[' to begin processing.
// ======================================================
ROOT_WS
    : [ \t]+ -> skip
    ;

NEWLINE
    : '\r'? '\n' 
    | '\r'
    ;

ROOT_TAG_OPEN
    : '[' -> type(TAG_OPEN), pushMode(MODE_TAG_START)
    ;

// ======================================================
// MODE: TAG START
// Disambiguation state. Determines if the tag is Metadata 
// (e.g., [ar:Artist]) or a Timestamp (e.g., [01:23.45]) based 
// on the first character found.
// ======================================================
mode MODE_TAG_START;

    DECIDE_ID_KEY
        : ~[0-9:]+ -> type(ID_KEY), popMode, pushMode(MODE_ID_BODY)
        ;

    DECIDE_TIME_MINUTES
        : [0-9]+ -> type(TIME_NUM), popMode, pushMode(MODE_TIME_BODY)
        ;

// ======================================================
// MODE: ID BODY
// Handles the parsing of the Metadata Key, waiting for the
// separator colon ':'.
// ======================================================
mode MODE_ID_BODY;

    ID_SEPARATOR
        : ':' -> type(COLON), pushMode(MODE_ID_VALUE)
        ;

// ======================================================
// MODE: ID VALUE
// Captures the text content of a Metadata tag and handles
// the closing bracket ']'.
// ======================================================
mode MODE_ID_VALUE;

    ID_CONTENT
        : ~[\r\n\]]+ -> type(ID_VALUE)
        ; 
    
    ID_TAG_CLOSE
        : ']' -> type(TAG_CLOSE)
        ;

    ID_NEWLINE
        : [ \t]* ('\r'? '\n' | EOF) -> type(NEWLINE), popMode, popMode
        ;

// ======================================================
// MODE: TIME BODY
// Parses the internal structure (mm:ss.xx) of a standard
// line-start timestamp.
// ======================================================
mode MODE_TIME_BODY;

    STD_TIME_COLON
        : ':' -> type(COLON)
        ;

    STD_TIME_DOT
        : '.' -> type(DOT)
        ;

    STD_TIME_DIGITS
        : [0-9]+ -> type(TIME_NUM)
        ;

    STD_TIME_CLOSE
        : ']' -> type(TAG_CLOSE), popMode, pushMode(MODE_POST_TAG)
        ;

    // Fallback for non-time characters inside a time tag
    STD_TIME_FALLBACK_TEXT
        : ~[ \t:.0-9\]\r\n]+ -> type(LYRICS_TEXT)
        ;

// ======================================================
// MODE: POST TAG
// The central content state. Handles standard lyrics text, 
// or detects transitions to Chained Timestamps ('[') or 
// Enhanced Word-level tags ('<').
// ======================================================
mode MODE_POST_TAG;

    // Starts an Enhanced LRC word tag <00:00>
    START_WORD_TAG
        : '<' -> type(SUB_TIME_TAG_OPEN), popMode, pushMode(MODE_SUB_TIME_TAG_START)
        ;

    // Starts a Chained timestamp [00:00][00:01]
    START_CHAINED_TAG
        : '[' -> type(TAG_OPEN), popMode, pushMode(MODE_POST_TAG_TIME_BODY)
        ;

    POST_TAG_WS
        : [ \t]+ -> type(SPACE)
        ;

    // Actual Lyrics content
    LYRICS_CONTENT
        : ~[ \t\r\n<[] ~[\r\n]* -> type(LYRICS_TEXT)
        ;

    POST_TAG_NEWLINE
        : [\r\n]+ -> type(NEWLINE), popMode
        ;

// ======================================================
// MODE: CHAINED TIME BODY
// Parses a secondary "chained" timestamp (e.g., the second 
// bracket in [00:01][00:02]) immediately following another.
// ======================================================
mode MODE_POST_TAG_TIME_BODY;

    CHAIN_TIME_COLON
        : ':' -> type(COLON)
        ;

    CHAIN_TIME_DOT
        : '.' -> type(DOT)
        ;

    CHAIN_TIME_DIGITS
        : [0-9]+ -> type(TIME_NUM)
        ;

    CHAIN_TIME_CLOSE
        : ']' -> type(TAG_CLOSE), popMode, pushMode(MODE_TIME_POST_TAG)
        ;

    CHAIN_TIME_FALLBACK_TEXT
        : ~[ \t:.0-9\]\r\n]+ -> type(LYRICS_TEXT)
        ;

    CHAIN_NEWLINE
        : [\r\n]+ -> type(NEWLINE), popMode
        ;

// ======================================================
// MODE: CHAINED POST TAG
// Consumes lyrics text that appears specifically after a 
// sequence of chained timestamps.
// ======================================================
mode MODE_TIME_POST_TAG;

    START_CHAINED2_TAG
        : '[' -> type(TAG_OPEN), popMode, pushMode(MODE_POST_TAG_TIME_BODY)
        ;

    CHAIN_TAG_WS
        : [ \t]+ -> type(SPACE)
        ;

    CHAIN_LYRICS_CONTENT
        : ~[ \t\r\n[] ~[\r\n]* -> type(LYRICS_TEXT)
        ;

    CHAINED_NEWLINE
        : [\r\n]+ -> type(NEWLINE)
        ;

// ======================================================
// MODE: WORD TIME START
// Parses the internal time components inside angle brackets 
// (<...>) for Enhanced LRC word-level timing.
// ======================================================
mode MODE_SUB_TIME_TAG_START;

    WORD_TIME_COLON
        : ':' -> type(COLON)
        ;

    WORD_TIME_DOT
        : '.' -> type(DOT)
        ;

    WORD_TIME_DIGITS
        : [0-9]+ -> type(TIME_NUM)
        ;

    // Handling nested '<' inside a word tag
    WORD_TIME_UNEXPECTED_OPEN
        : '<' -> type(SUB_TIME_TAG_OPEN)
        ;

    WORD_TIME_FALLBACK_TEXT
        : ~[:.0-9><\r\n]+ -> type(LYRICS_TEXT)
        ;

    WORD_TIME_CLOSE
        : '>' -> type(SUB_TIME_TAG_CLOSE), popMode, pushMode(MODE_POST_SUB_TIME_TAG)
        ;

    WORD_TIME_NEWLINE
        : [\r\n]+ -> type(NEWLINE), popMode
        ;

// ======================================================
// MODE: POST WORD TAG
// Captures lyrics text falling between word-level tags, or 
// detects the start of the next word tag.
// ======================================================
mode MODE_POST_SUB_TIME_TAG;

    NEXT_WORD_TAG_OPEN
        : '<' -> type(SUB_TIME_TAG_OPEN), popMode, pushMode(MODE_SUB_TIME_TAG_START)
        ;

    POST_SUB_TIME_CLOSE
        : '>' -> type(SUB_TIME_TAG_CLOSE)
        ;

    WORD_LYRICS_CONTENT
        : ~[>\r\n<] ~[>\r\n<]* -> type(LYRICS_TEXT)
        ;

    WORD_NEWLINE
        : [\r\n]+ -> type(NEWLINE), popMode
        ;