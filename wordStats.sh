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

# Words read
declare -A WORDS

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

# Prints array before sort
print_array() {
    for word in "${!WORDS[@]}"; do
        printf "%s\t\t%s\n" "${WORDS[$word]}" "$word"
    done
}

# Sorts WORDS array by a given order
sort_array() {
    if [ "$1" == "" ]; then
        echo "Incorrect usage."
        echo "Set a direction asc desc."
        return
    fi

    case "${1}" in
    "asc")
        print_array | sort -n -k2
        ;;
    "desc")
        print_array | sort -rn -k2
        ;;
    *)
        echo "Direction not suported"
        ;;
    esac

}

prepare_print() {
    count=0
    jump=0
    for line in $(eval $1); do
        if [ $jump == 0 ]; then
            jump=1
            ((count = count + 1))
            printf "\t%d\t\t%s" "$count" "$line"
        else
            jump=0
            printf "\t%s\n" "$line"
        fi
    done

    unset count
    unset jump
}

# Reads the content of an input file path
# Variable WORDS as output
count_words() {
    if [ "$1" == "" ]; then
        echo "Incorrect usage."
        echo "Input an existing file."
        return
    fi

    WORDS=()
    WORDS_LENGHT=0

    for line in $(<$1); do
        for word in $line; do
            if $STOP_WORDS_STATUS; then
                # Sorry the in_array function did not work with regex :(
                if [[ "${STOP_WORDS[*]}" =~ ${word/$'\r'/} ]]; then
                    continue
                else
                    if index_in_array word in WORDS; then
                        ((WORDS["$word"] = WORDS["$word"] + 1))
                    else
                        ((WORDS_LENGHT = WORDS_LENGHT + 1))
                        WORDS["$word"]=1
                    fi
                fi
            else
                if index_in_array word in WORDS; then
                    ((WORDS["$word"] = WORDS["$word"] + 1))
                else
                    ((WORDS_LENGHT = WORDS_LENGHT + 1))
                    WORDS["$word"]=1
                fi
            fi

        done

    done
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
    echo "Stopwords filtered"
    STOP_WORDS_STATUS=true
    count_words "$FILE"
    prepare_print 'sort_array "desc"' >$OUTPUT_FILE
    STOP_WORDS_STATUS=false
    ;;
"C")
    echo "Stopwords ignored"
    count_words "$FILE"
    prepare_print 'sort_array "desc"' >$OUTPUT_FILE
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
