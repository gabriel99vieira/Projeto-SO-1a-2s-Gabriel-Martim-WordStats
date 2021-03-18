#!/bin/bash

# whatis tr
# whatis cut
# whatis grep
# whatis sort
# whatis uniq
# whatis nl

echo

split_words() {
    for word in $(cat $1); do
        echo $word
    done
}

FILE="tests/teste.txt"
OUTPUT="resuts/teste---result.txt"
WORDS="lang/pt.stop_words.txt"

echo "remove list"
split_words $FILE | sort | grep -w -v -i -f $WORDS | uniq -c | sort -rn | cat -n

echo
echo "dont remove"
split_words $FILE | sort | uniq -c | sort -rn | cat -n

echo
