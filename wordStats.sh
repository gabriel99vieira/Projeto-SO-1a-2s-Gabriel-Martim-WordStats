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
WORD_STATS_TOP=10

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
    echo "Closing..."
    exit 0
}

# if exists {parameter} in {array}; then ... fi
exists() {
    if [ "$2" != in ]; then
        echo "Incorrect usage."
        echo "Correct usage: exists {key} in {array}"
        return
    fi
    eval '[[ " ${'"$3"'[@]} " =~ " ${'"$1"'} " ]]'
}

# if index_exists {index} in {array}; then ... fi
index_exists() {
    if [ "$2" != in ]; then
        echo "Incorrect usage."
        echo "Correct usage: exists {key} in {array}"
        return
    fi
    eval '[ '"$3"'["'"$1"'"] ]'
}

# Verify if a file exists
file_exists() {
    eval '[[ -f "${'"$1"'}" ]]'
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
if exists MODE in MODES; then
    echo "Executing on mode '$MODE'."
else
    echo "Function '$MODE' is not implemented."
    close
fi

# Check if file exists
if file_exists FILE; then

    # get file extension
    extension="${FILE##*.}"

    # check if file type is allowed
    # if [[ ${FILE_TYPES["${extension}"]} ]]; then
    if index_exists extension in FILE_TYPES; then
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
if exists ISO in ISOS; then
    echo "ISO will use '$ISO' format."
else
    ISO="en"
    echo "ISO not defined. Default will be used ('$ISO')."
fi
STOP_WORD_FILE="$LANG_PATH/$ISO.$STOP_WORD_FILE"
1
if file_exists STOP_WORD_FILE; then
    echo "Stop words file: $STOP_WORD_FILE."
else
    echo "File not found"
    # TODO caso não encontre criar ficheiro com caminho (LANG_PATH)
fi
echo ""

#
# ───────────────────────────────────────────────────────────────────── CODE ─────
#

case $MODE in

"c")
    echo "Count sem stopwords"
    ;;
"C")
    echo "Count com stopwords"
    ;;

"p")
    echo "Plot sem stopwords"
    ;;

"P")
    echo "Plot com stopwords"
    ;;

"t")
    echo "Top sem stopwords"
    ;;
"T")
    echo "Top com stopwords"
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
