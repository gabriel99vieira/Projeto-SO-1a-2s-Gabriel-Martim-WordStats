#!/bin/bash

# whatis tr
# whatis cut
# whatis grep
# whatis sort
# whatis uniq
# whatis nl

split_words() {
    for word in $(cat $1); do
        echo $word
    done
}

FILE="samples/test.txt"
WORDS="lang/pt.stop_words.txt"

touch .tmp_sw
WORDS_LF=".tmp_sw"

tr -d '\015' <$WORDS >$WORDS_LF

split_words $FILE | sed $'s/\r$//' | tr -d '.,«»;?' | awk NF | tr -t '\r' '' | sort | grep -w -v -i -f $WORDS_LF | uniq -c | sort -rn | cat -n

rm -f $WORDS_LF
