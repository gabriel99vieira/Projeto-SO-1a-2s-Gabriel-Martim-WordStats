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

FILE="samples/sample.pt.txt"
WORDS="lang/pt.stop_words.txt"

split_words $FILE | tr -d '.,«»;?' | awk NF | tr -t '\r' '' | sort | grep -w -v -i -f $WORDS | uniq -c | sort -rn | cat -n

# echo
# echo "dont remove"
# split_words $FILE | sort | uniq -c | sort -rn | cat -n

# echo
