parser grammar LRCMixedParser;

options { tokenVocab = LRCExtendLexer; }

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
    : timeTag (SPACE* subtimeTag lyrics*)+
    ;

lineLevelTimeLine
    : SPACE* timeTag lyrics2+
    | SPACE* timeTag (SPACE* timeTag)+ lyrics*
    ;

emptyContentTimeLine
    : SPACE* timeTag lyrics3
    ;

timeTag
    : TAG_OPEN min=TIME_NUM COLON sec=TIME_NUM DOT ms=TIME_NUM TAG_CLOSE
    ;

lyrics
    : (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN | TIME_NUM | COLON | DOT)+
    ;

lyrics2
    : SPACE+ (TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN) (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN)*
    | (TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN) (SPACE | TAG_OPEN | TAG_CLOSE | LYRICS_TEXT | SUB_TIME_TAG_OPEN)*
    ;

lyrics3
    : SPACE*
    ;

subtimeTag
    : SUB_TIME_TAG_OPEN min=TIME_NUM COLON sec=TIME_NUM DOT ms=TIME_NUM SUB_TIME_TAG_CLOSE
    ;