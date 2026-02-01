parser grammar LRCMixedParser;

options { tokenVocab = LRCMixedLexer; }

lrcFile
    : NEWLINE* idSection? timeSection? EOF
    ;

idSection
    : (idLine NEWLINE*)+
    ;

timeSection
    : (
        wordLevelTimeLine NEWLINE*
        | 
        lineLevelTimeLine NEWLINE*
        |
        emptyContentTimeLine NEWLINE*
      )+
    ;

idLine
    : TAG_OPEN key=ID_KEY COLON idValue TAG_CLOSE
    ;

idValue
    : (ID_VALUE | TAG_CLOSE)* 
    ;

wordLevelTimeLine
    : timeTag SPACE* subtimeTag 
      (
        (lyrics subtimeTag)*
        |
        (lyrics subtimeTag)+ lyrics
      )
    ;

lineLevelTimeLine
    : SPACE* timeTag lyrics1+
    | SPACE* timeTag (SPACE* timeTag)+ lyrics2*
    ;

emptyContentTimeLine
    : SPACE* timeTag lyrics3
    ;

timeTag
    : TAG_OPEN min=TIME_NUM COLON sec=TIME_NUM DOT ms=TIME_NUM TAG_CLOSE
    ;

lyrics1
    : SPACE+ (TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN) (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN)*
    | (TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN) (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN)*
    ;

lyrics2
    : (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN | SUB_TIME_TAG_CLOSE | TIME_NUM | COLON | DOT)+
    ;

lyrics3
    : SPACE*
    ;

subtimeTag
    : SUB_TIME_TAG_OPEN min=TIME_NUM COLON sec=TIME_NUM DOT ms=TIME_NUM SUB_TIME_TAG_CLOSE
    ;

lyrics
    // Denoted "d" as digits 
    // 1. matching charcters not starting from "<"
    : (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | TIME_NUM | COLON | DOT)* SUB_TIME_TAG_OPEN*
    // 2. matching charcters starting from "<" but not followed by "d"
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (LYRICS_TEXT | SUB_TIME_TAG_CLOSE | COLON | DOT)+
    // 3. matching charcters starting from "<d" but not followed by ":"
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | COLON | DOT) (LYRICS_TEXT | SUB_TIME_TAG_OPEN | SUB_TIME_TAG_CLOSE | TIME_NUM | DOT)*
    // 4. matching charcters starting from "<d:" but not followed by "d"
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT) (TIME_NUM | COLON+) (LYRICS_TEXT | SUB_TIME_TAG_OPEN | SUB_TIME_TAG_CLOSE | COLON | DOT)*
    // 5. matching charcters starting from "<d:d" but not followed by "."
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT) (TIME_NUM | COLON+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT | COLON+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_OPEN | SUB_TIME_TAG_CLOSE | COLON)*
    // 6. matching charcters starting "<d:d." but not followed by "d"
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT) (TIME_NUM | COLON+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT | COLON+) (TIME_NUM | DOT+) (LYRICS_TEXT | SUB_TIME_TAG_OPEN | SUB_TIME_TAG_CLOSE | COLON | DOT)*
    // 7a. matching charcters starting "<d:d.d" but not followed by ">", and ended with not characters ">"
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT) (TIME_NUM | COLON+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT | COLON+) (TIME_NUM | DOT+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_OPEN | COLON | DOT)+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_OPEN | COLON | DOT)*
    // 7b. matching charcters starting "<d:d.d" but not followed by ">", and ended with not characters "d"
    | LYRICS_TEXT* SUB_TIME_TAG_OPEN+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT) (TIME_NUM | COLON+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_CLOSE | DOT | COLON+) (TIME_NUM | DOT+) (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_OPEN | COLON | DOT)+ (TIME_NUM | LYRICS_TEXT | SUB_TIME_TAG_OPEN | COLON | DOT)+ (LYRICS_TEXT | SUB_TIME_TAG_OPEN | SUB_TIME_TAG_CLOSE | COLON | DOT)*
    ;