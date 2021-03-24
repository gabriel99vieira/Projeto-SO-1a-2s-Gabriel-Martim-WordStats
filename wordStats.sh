#!/bin/bash

#
# ───────────────────────────────────────────────────────── GLOBAL VARIABLES ─────
#

# Input variables
MODE=$1
FILE=$2
ISO=$3

# StopWords files
# Example pt.stop_words.txt
STOP_WORDS_FILE="stop_words.txt"
LANG_PATH="./lang"
EXTRA_CHARS='.,]:«}#/»=\;"(*<>)|?{•–[-'

# Stopwords related variables
# WORD_STATS_TOP=10 # !!! Changed to environment cariable (lines +-280)
WORD_STATS_TOP_DEFAULT=10
WORD_STATS_TOP=$(printenv WORD_STATS_TOP)

#GNUPlot
GNU_PLOT_TEMP_FILE=".temp_plot"
GNU_PLOT_OUTPUT=".png"
GNU_PLOT_OUTPUT_HTML=".html"

# Default preview lenght
PREVIEW_LENGHT=10

# Input files
WORDS_LF=".temp_sw"

# Output file
OUTPUT_FILE="results/result---"
OUTPUT_FILE_FORMAT="txt"
OUTPUT_TEMP=".temp_out"

# Allowed ISOs
ISOS=("pt" "en")

# Allowed output modes
MODES=("c" "C" "t" "T" "p" "P")

# Allowed file types
declare -A FILE_TYPES
FILE_TYPES["txt"]="Text"
FILE_TYPES["pdf"]="PDF"

#
# ──────────────────────────────────────────────────────────────── FUNCTIONS ─────
#

# Sets a color for the next console output
# USAGE: color "red|green|blue|yellow|cyan" # to change color
# USAGE: color # to reset
color() {
    case "${1}" in
    "red")
        echo -e -n "\e[31m"
        ;;
    "green")
        echo -e -n "\e[92m"
        ;;
    "blue")
        echo -e -n "\e[34m"
        ;;
    "yellow")
        echo -e -n "\e[93m"
        ;;
    "cyan")
        echo -e -n "\e[36m"
        ;;
    *)
        echo -e -n "\e[39m"
        ;;
    esac
    if [ "${1}" == "" ]; then
        echo -e -n "\e[39m"
    fi
}

# Prints a start log with the specified category name and respective color
# USAGE: log "info|warn|error"
log() {
    case "${1}" in
    "error")
        color "red"
        printf "[ERROR]\t"
        ;;
    "warn")
        color "yellow"
        printf "[WARN]\t"
        ;;
    "info")
        color "cyan"
        printf "[INFO]\t"
        ;;
    "exec")
        color "green"
        printf "[EXEC]\t"
        ;;
    esac
    color
}

# Exits the current execution with a message
# USAGE: close
close() {
    echo
    echo "Closing..."
    exit 0
}

# Verifies if a value exists/is set in the array
# USAGE: if in_array {parameter} in {array}; then ... fi
in_array() {
    if [ "$2" != in ]; then
        echo "!!! Incorrect usage of 'in_array'"
        echo "Correct usage: in_array {key} in {array}"
        return
    fi
    eval '[[ " ${'"$3"'[@]} " =~ " ${'"$1"'} " ]]'
}

# Verifies if a index exists/is set in the array
# USAGE: if index_in_array {index} in {array}; then ... fi
index_in_array() {
    if [ "$2" != in ]; then
        echo "!!! Incorrect usage of 'index_in_array'"
        echo "Correct usage: in_array {key} in {array}"
        return
    fi
    eval '[ '"$3"'["'"$1"'"] ]'
}

# Verifies if input is number
# WARNING: function input must be string format (for variables)
# USAGE: if is_number $NUMBER; then ... fi
is_number() {
    if [ "$1" == "" ]; then
        log "error"
        echo "Incorrect usage of 'is_number'. 1st argument required."
        close
    fi

    if [[ $1 =~ ^[+-]?[0-9]+$ ]]; then
        return 0

    elif [[ $1 =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
        return 0
    fi
    return 1
}

# todo comment
is_capital() {
    if [[ $1 =~ [A-Z] ]]; then
        return 0
    fi
    return 1
}

# Verifies if a file exists
# USAGE: if file_exists FILE_PATH; then ... fi
file_exists() {
    if [ "$1" == "" ]; then
        log "error"
        echo "Incorrect usage of 'file_exists'. 1st argument required."
        close
    fi
    eval '[[ -f "${'"$1"'}" ]]'
}

# Splits the content of a file in words
# USAGE: split_words $FILE_PATH
split_words() {
    if [ "$1" == "" ]; then
        echo "!!! Incorrect usage of 'split_words'"
        echo "A file path must be passed."
        return
    fi
    for word in $(cat $1); do
        echo $word
    done
}

# Prints from a specific file the ammount of lines provided
# USAGE: print_preview $FILE_PATH {int}
print_preview() {
    if [ "$1" == "" ]; then
        echo "!!! Incorrect usage of 'print_preview'."
        echo "A file path must be passed as 1st parameter."
        return
    fi
    re='^[0-9]+$'
    if ! [[ $2 =~ $re ]]; then
        echo "!!! Incorrect usage of 'print_preview'."
        echo "A number must be passed as 2nd parameter."
        return
    fi
    unset re
    eval 'head -$2 $1'
    if [ "$(wc -l <"$1")" -gt "$2" ]; then
        printf "\t\t%s" "(...)"
        echo
    fi
}

# todo comment
# todo refactor
plot() {

    GNU_PLOT_OUTPUT=$OUTPUT_FILE$GNU_PLOT_OUTPUT
    GNU_PLOT_OUTPUT_HTML=$OUTPUT_FILE$GNU_PLOT_OUTPUT_HTML

    if ! file_exists GNU_PLOT_TEMP_FILE; then
        touch $GNU_PLOT_TEMP_FILE
    fi
    true >$GNU_PLOT_TEMP_FILE
    {
        stpwords=""
        if is_capital $MODE; then
            stpwords="No"
        else
            stpwords="Yes ($ISO)"
        fi

        echo "set title \"Top words for $FILE\n$(date +'%A %B %Y %H:%M')\nStopwords: $stpwords\""
        echo "set terminal png"
        echo "set autoscale y"
        echo "set output \"$GNU_PLOT_OUTPUT\""
        echo "set boxwidth 0.6"
        echo "set style fill solid"
        echo "set xlabel \"Words\" font \"bold\""
        echo "set xtics rotate by -45"
        echo "set ylabel \"Quantity\" font \"bold\""
        # echo "set ytics 1"
        echo "set grid ytics linestyle 1 linecolor rgb \"#e6e6e6\""
        echo "set key top"
        echo "plot \"$OUTPUT_FILE\" using 1:2:xtic(3) with boxes title 'Occurrences' linecolor rgb \"#3399ff\""
    } >"$GNU_PLOT_TEMP_FILE"
    unset stpwords

    gnuplot <"$GNU_PLOT_TEMP_FILE"

    {
        echo "<html><div "
        echo "style=\"display: block; margin-left: auto; margin-right: auto; width: 40%; margin-top: 5%;"
        echo "><img src=\"./../$GNU_PLOT_OUTPUT\"></div></html>"
    } >$GNU_PLOT_OUTPUT_HTML

    echo
    log "info"
    echo "Opening preview..."
    xdg-open $GNU_PLOT_OUTPUT >/dev/null 2>&1 &

}

# todo comment
c_mode() {
    # Checks what mode the user entered
    cmd=""
    if [ "$MODE" == "c" ]; then
        log "exec"
        echo "STOPWORDS FILTERED"
        # Saves command to filter the stopwords
        cmd="sort | grep -w -v -i -f $STOP_WORDS_FILE"
    elif [ "$MODE" == "C" ]; then
        log "exec"
        echo "STOPWORDS IGNORED"
        # Saves command without the grep to ignore Stopwords
        cmd="sort"
    fi

    # Results will be presented in a file
    # Prints PREVIEW_LENGHT to console
    split_words $FILE | tr -d "'" | tr -d "$EXTRA_CHARS" | awk NF | eval $cmd | uniq -c -i | sort -rn | cat -n | tr -d '\t' >$OUTPUT_FILE
    unset cmd
    ls -lah $OUTPUT_FILE
    echo "-------------------------------------"
    print_preview $OUTPUT_FILE $PREVIEW_LENGHT
}

# todo comment
t_mode() {
    # Checks what mode the user entered
    cmd=""
    if [ "$MODE" == "t" ]; then
        # Saves command to filter the stopwords
        cmd="sort | grep -w -v -i -f $STOP_WORDS_FILE"
        log "exec"
        echo "STOPWORDS FILTERED"
    elif [ "$MODE" == "T" ]; then
        # Saves command without the grep to ignore Stopwords
        cmd="sort"
        log "exec"
        echo "STOPWORDS IGNORED"
        log "exec"
        echo "WORD_STATS_TOP =" $WORD_STATS_TOP
    fi

    # Results will be presented in a file
    # Prints PREVIEW_LENGHT to console
    split_words $FILE | tr -d "'" | tr -d "$EXTRA_CHARS" | awk NF | eval $cmd | uniq -c -i | sort -rn | cat -n | tr -d '\t' | sed -n 1,"$WORD_STATS_TOP"p >$OUTPUT_FILE
    unset cmd
    ls -lah $OUTPUT_FILE
    echo "-------------------------------------"
    echo " # TOP $WORD_STATS_TOP elements"
    print_preview $OUTPUT_FILE $WORD_STATS_TOP
}

# todo comment
p_mode() {
    if [ "$MODE" == "p" ]; then
        MODE="t"
    elif [ "$MODE" == "P" ]; then
        MODE="T"
    fi
    t_mode
    plot
}

#
# ───────────────────────────────────────────────────────────────────── BOOT ─────
#

clear

echo "Starting..."
echo

# Evaluate inputs before proceed
# In the following code bellow any value not properly assigned causes the program to exit

# Check if mode is allowed
if in_array MODE in MODES; then
    log "info"
    echo "Executing on mode '$MODE'."
else
    if [ -n "${MODE}" ]; then
        log "error"
        echo "Mode required do execute [C/c|P/p|T/t]"
    else
        log "error"
        echo "unknown command '$MODE'"
    fi
    close
fi

# Check if file exists (and different than "") and the extension is allowed/supported
if file_exists FILE; then

    # get file extension
    extension="${FILE##*.}"

    # check if file type is allowed
    if index_in_array extension in FILE_TYPES; then
        log "info"
        echo "Opening '$FILE' as ${FILE_TYPES[${extension}]} file."
    else
        log "error"
        echo "File extension '$extension' not allowed."
        close
    fi
else
    log "error"
    if [ -n "${FILE}" ]; then
        echo "File not provided."
    else
        echo "File '$FILE' not found!"
    fi
    close
fi

# Check if ISO is suported, else use default "en"
if in_array ISO in ISOS; then
    log "info"
    echo "ISO format: '$ISO'."
else
    ISO="en"
    log "warn"
    echo "ISO not defined. Default will be used ('$ISO')."
fi

#
# If it reaches here means that
#       ISO is correct and enabled in the ISOS array
#       File exists and its type is supported
#

# Evaluates if Environment variable WORD_STATS_TOP is assigned
#       If assigned then proceeds the normal execution
#       Else warn pops up in console and a default is assigned by WORD_STATS_TOP_DEFAULT variable
if [ "${WORD_STATS_TOP}" == "" ]; then
    export WORD_STATS_TOP=$((WORD_STATS_TOP_DEFAULT))
    log "warn"
    echo "WORD_STATS_TOP not defined. Default used ($WORD_STATS_TOP_DEFAULT)"
else
    if is_number $WORD_STATS_TOP; then
        log "info"
        echo "WORD_STATS_TOP: $WORD_STATS_TOP"
    else
        export WORD_STATS_TOP=$((WORD_STATS_TOP_DEFAULT))
        log "warn"
        echo "WORD_STATS_TOP not a number. Default used ($WORD_STATS_TOP_DEFAULT)"
    fi
fi

# Sets the STOP_WORDS_FILE path and checks its existance
# In case it doesn't exist, one is created empty and a warning pops up
STOP_WORDS_FILE="$LANG_PATH/$ISO.$STOP_WORDS_FILE"
if file_exists STOP_WORDS_FILE; then
    log "info"
    echo "Stop words file: $STOP_WORDS_FILE. ($(wc -l <$STOP_WORDS_FILE))"
else
    # Creates the ISO file
    touch $STOP_WORDS_FILE
    log "warn"
    echo "Stop words file not found ... creating empty"
fi

# Sets the 'filename' variable the same as input
filename=$(basename -- "$FILE")
filename="${filename%.*}"

# Defines global OUTPUT_FILE for easy manipulation
OUTPUT_FILE="$OUTPUT_FILE$filename.$OUTPUT_FILE_FORMAT"

# Checks if the OUTPUT_FILE exists
# In case it exists warns that it will be overwritten
# If it doesn't exist, one will be created
if file_exists OUTPUT_FILE; then
    log "warn"
    echo "Output file will be overwritten: '$OUTPUT_FILE'"
    true >"$OUTPUT_FILE"
    touch "$OUTPUT_FILE"
else
    log "info"
    echo "Creating new output file: '$OUTPUT_FILE'"
    touch "$OUTPUT_FILE"
fi

#
# ─────────────────────────────────────────────────────── COMPATIBILITY AREA ─────
#
# This area is used to convert different file formats into the default (txt)
# If this step is well written, then the following code will work without any change

# Converting PDF contents into Text
if [ "${extension}" == "pdf" ]; then
    touch $OUTPUT_TEMP
    pdftotext -layout $FILE $OUTPUT_TEMP
    FILE=$OUTPUT_TEMP
fi

# Convert CRLF to LF EOL sequence to prevent bugs
touch $WORDS_LF
tr -d '\015' <$STOP_WORDS_FILE >$WORDS_LF
STOP_WORDS_FILE=$WORDS_LF

#
# ────────────────────────────────────────────────────────────── BEFORE CODE ─────
#
# Here variables that will no longer be used can be deleted
# Or extra functions can be executed before proceeding

unset filename
unset extension

#
# ───────────────────────────────────────────────────────────────────── CODE ─────
#

echo
echo "Executing..."
echo
case $MODE in

"c" | "C")
    c_mode
    ;;

"p" | "P")
    p_mode
    ;;
"t" | "T")
    t_mode
    ;;

esac

#
# ───────────────────────────────────────────────────────────────── END CODE ─────
#

#
# ────────────────────────────────────────────────────────────────── CLOSING ─────
#
# Here aditional temporary files can be deleted and extra code can
# be implemented before closing the script

# Removing the temporary PDF content file
rm -f $OUTPUT_TEMP
rm -f $WORDS_LF
rm -f $GNU_PLOT_TEMP_FILE

# Exiting the program
close

# ────────────────────────────────────────────────────────────────────────────────
