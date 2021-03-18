#!/bin/bash

#
# ───────────────────────────────────────────────────────── GLOBAL VARIABLES ─────
#

# Input
MODE=$1
FILE=$2
ISO=$3

# StopWords file
# Example pt.stop_words.txt
STOP_WORD_FILE="stop_words.txt"
LANG_PATH="./lang"

# Words variables
declare -A WORDS
declare -A SORTED_WORDS
WORDS_LENGHT=0

# Stopwords related
WORD_STATS_TOP=10
STOP_WORDS_STATUS=false
STOP_WORDS=()

# Output file
OUTPUT_FILE="results/result---"
OUTPUT_FILE_FORMAT="txt"

# Allowed ISO format
ISOS=("pt" "en")

# Allowed modes
MODES=("c" "C" "t" "T" "p" "P")

# Allowed file types
declare -A FILE_TYPES
FILE_TYPES["txt"]="Text"
FILE_TYPES["pdf"]="PDF"

#
# ──────────────────────────────────────────────────────────────── FUNCTIONS ─────
#

close() {
    echo
    echo "Done..."
    exit 0
}

# if in_array {parameter} in {array}; then ... fi
in_array() {
    if [ "$2" != in ]; then
        echo "Incorrect usage."
        echo "Correct usage: in_array {key} in {array}"
        return
    fi
    eval '[[ " ${'"$3"'[@]} " =~ " ${'"$1"'} " ]]'
}

# if index_in_array {index} in {array}; then ... fi
index_in_array() {
    if [ "$2" != in ]; then
        echo "Incorrect usage."
        echo "Correct usage: in_array {key} in {array}"
        return
    fi
    eval '[ '"$3"'["'"$1"'"] ]'
}

# Verify if a file exists
file_exists() {
    eval '[[ -f "${'"$1"'}" ]]'
}

split_words() {
    for word in $(cat $1); do
        echo $word
    done
}

print_preview() {
    eval 'head -$2 $1'
    if [ "$(wc -l <"$1")" -gt "$2" ]; then
        printf "\t\t%s" "(...)"
        echo
    fi
}

#
# ───────────────────────────────────────────────────────────────────── BOOT ─────
#

clear

#
# ─────────────────────────────────────────────────────────── VALIDATE INPUT ─────
#

# Evaluate inputs before proceed

# Check if mode is permited
# if [[ " ${MODES[@]} " =~ " ${MODE} " ]]; then
if in_array MODE in MODES; then
    echo "Executing on mode '$MODE'."
else
    if [ "$MODE" = "" ]; then
        echo "Mode required do execute."
    else
        echo "Mode '$MODE' is not implemented."
    fi
    close
fi

# Check if file exists
if file_exists FILE; then

    # get file extension
    extension="${FILE##*.}"

    # check if file type is allowed
    # if [[ ${FILE_TYPES["${extension}"]} ]]; then
    if index_in_array extension in FILE_TYPES; then
        echo "Opening '$FILE' as ${FILE_TYPES[${extension}]} file."
    else
        echo "File extension '$extension' not allowed."
        close
    fi
else
    echo "File '$FILE' does not exist."
    close
fi

# Check if iso is suported, else use default "en"
if in_array ISO in ISOS; then
    echo "ISO will use '$ISO' format."
else
    ISO="en"
    echo "ISO not defined. Default will be used ('$ISO')."
fi
STOP_WORD_FILE="$LANG_PATH/$ISO.$STOP_WORD_FILE"
if file_exists STOP_WORD_FILE; then
    echo "Stop words file: $STOP_WORD_FILE."
else
    echo "File not found"
    # TODO caso não encontre criar ficheiro com caminho (LANG_PATH)
fi

filename=$(basename -- "$FILE")
filename="${filename%.*}"

OUTPUT_FILE="$OUTPUT_FILE$filename.$OUTPUT_FILE_FORMAT"

if file_exists OUTPUT_FILE; then
    echo "Output file will be overwriten: '$OUTPUT_FILE'"
    true >"$OUTPUT_FILE"
    touch "$OUTPUT_FILE"
else
    echo "Creating new output file: '$OUTPUT_FILE'"
    touch "$OUTPUT_FILE"
fi

unset filename
unset extension

# Read stopwords file to an array
readarray -t STOP_WORDS <$STOP_WORD_FILE

#
# ───────────────────────────────────────────────────────────────────── CODE ─────
#

echo
case $MODE in

"c")
    echo "STOPWORDS FILTERED"
    split_words $FILE | sort | grep -w -v -i -f $STOP_WORD_FILE | uniq -c | sort -rn | cat -n >$OUTPUT_FILE
    echo
    print_preview $OUTPUT_FILE 10
    ;;
"C")
    echo "STOPWORDS IGNORED"
    split_words $FILE | sort | uniq -c | sort -rn | cat -n >$OUTPUT_FILE
    echo
    print_preview $OUTPUT_FILE 10
    ;;

"p")
    echo "Plot without stopwords"
    ;;

"P")
    echo "Plot with stopwords"
    ;;

"t")
    echo "Top without stopwords"
    ;;
"T")
    echo "Top with stopwords"
    ;;
esac

#
# ────────────────────────────────────────────────────────────────── CLOSING ─────
#

# save files

#
# ───────────────────────────────────────────────────────────────── END CODE ─────
#

close
