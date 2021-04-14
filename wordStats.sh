#!/bin/bash

#
# ────────────────────────────────────────────────────────────── SCRIPTED BY ─────
#

# Gabriel Madeira Vieira - 2200661 - Student at IPL - ESTG - Computer Engineering
# Martim Teixeira da Silva - 2200681 - Student at IPL - ESTG - Computer Engineering
# Operative Systems Project

#
# ───────────────────────────────────────────────────────── GLOBAL VARIABLES ─────
#

AUTHORS=("Gabriel Vieira - 2200661" "Martim Silva - 2200681")

# Input variables
MODE=$1
FILE=$2
ISO=$3

# StopWords files
# Example pt.stop_words.txt
STOP_WORDS_FILE="stop_words.txt"
LANG_PATH="./StopWords"
EXTRA_CHARS='.,]:«}#/»=\;"(*<>)|?{•–[-'

# Stopwords related variables
# WORD_STATS_TOP=10 # !!! Changed to environment cariable (lines +-425)
WORD_STATS_TOP_DEFAULT=10
WORD_STATS_TOP=$(printenv WORD_STATS_TOP)

# EOL LF fix temporary file for storpwords
WORDS_LF=".temp_sw"

# GNUPlot variables
GNU_PLOT_TEMP_FILE=".temp_plot"
GNU_PLOT_OUTPUT=".png"
GNU_PLOT_OUTPUT_HTML=".html"

# Default preview lenght when WORD_STATS_TOP isn't used for the required mode
PREVIEW_LENGHT=10

# Input variables
ORIGINAL_INPUT=$FILE # NEVER! change this variable!
FILE_LF=".temp_lf"   # For LF line break

# Output file variables
OUTPUT_FILE="results/result---" # ? File prefix - later is changed to full path output
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
# ? Example # FILE_TYPES["docx"]="Word document"

#
# ──────────────────────────────────────────────────────────────── FUNCTIONS ─────
#

# Actions executed before closing script
# This will be executed each time function 'close' is called
before_close() {

    rm -f $OUTPUT_TEMP        # Remove the temporary PDF content file
    rm -f $WORDS_LF           # Remove the temporary words LF file
    rm -f $GNU_PLOT_TEMP_FILE # Remove the temporary gnuplot configuration file
    rm -f $FILE_LF            # Remove the temporary LF input file
}

# Returns true if provided string is empty
# ? USAGE: if string_empty "$string"; then ... fi
string_empty() {
    if [ -z "${1}" ]; then
        return 0
    fi
    return 1
}

# Returns true if both strings are equal/match
# ! MAX 2 strings
# ? USAGE: if string_equal "$string1" "$string2"; then ... fi
string_equal() {
    if [ "${1}" = "${2}" ]; then
        return 0
    fi
    return 1
}

# Verifies if input is number
# WARNING: function input must be string format (for variables)
# ? USAGE: if is_number $NUMBER; then ... fi
is_number() {
    if string_empty "$1"; then
        log "error" "Incorrect usage of 'is_number'. 1st argument required."
        close
    fi

    # Regex from https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash
    if [[ $1 =~ ^[+-]?[0-9]+$ ]]; then
        return 0

    elif [[ $1 =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
        return 0
    fi
    return 1
}

# Returns true if provided char is a capital letter
# ? USAGE: if is_capital_letter "$char"; then ... fi
is_capital_letter() {
    if string_empty "$1"; then
        log "error" "Incorrect usage of 'is_capital_letter'. 1st argument required."
        close
    fi

    if [[ $1 =~ [A-Z] ]]; then
        return 0
    fi
    return 1
}

# Sets a color for the next console output
# ? USAGE: color "red|green|blue|yellow|cyan" # to change color
# ? USAGE: color # to reset
color() {
    # color from https://stackoverflow.com/questions/9084257/bash-array-with-spaces-in-elements
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
# ? USAGE: log "info|warn|error"
# ? USAGE: log "info|warn|error" "Description"
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

    if ! string_empty "$2"; then
        echo "$2"
    fi
}

# Exits the current execution with a message
# ? USAGE: close
close() {
    echo
    echo "Closing..."
    before_close
    exit 0
}

# Verifies if a value exists/is set in the array
# ? USAGE: if in_array ${parameter} in ${array}; then ... fi
in_array() {
    if [ "$2" != in ]; then
        log "error" "Incorrect usage of 'in_array'. Correct usage: in_array {key} in {array}"
        close
    fi

    eval '[[ " ${'"$3"'[@]} " =~ " ${'"$1"'} " ]]'

}

# Verifies if a index exists/is set in the array
# ? USAGE: if index_in_array ${index} in {array}; then ... fi
index_in_array() {
    if [ "$2" != in ]; then
        log "error" "Incorrect usage of 'index_in_array'. Correct usage: in_array {key} in {array}"
        return
    fi
    if string_empty "$1"; then
        log "error" "Incorrect usage of 'index_in_array'. 1st argument required."
        close
    fi
    if [[ -v $3[$1] ]]; then
        return 0
    fi
    return 1
    # eval '[ ${'"$3"'[$1]} ]'
    # eval '[ '"$3"'["'"$1"'"] ]'
}

# Verifies if a file exists
# ? USAGE: if file_exists FILE_PATH; then ... fi
file_exists() {
    if string_empty "$1"; then
        log "error" "Incorrect usage of 'file_exists'. 1st argument required."
        close
    fi
    eval '[[ -f "${'"$1"'}" ]]'
}

# Splits the content of a file in words
# ? USAGE: split_words $FILE_PATH
split_words() {
    if string_empty "$1"; then
        log "error" "Incorrect usage of 'split_words'. A file path must be passed."
        close
    fi
    for word in $(cat $1); do
        echo $word
    done
}

# Prints from a specific file the ammount of lines provided
# ? USAGE: print_preview $FILE_PATH {int}
print_preview() {
    if string_empty "$1"; then
        log "error" "Incorrect usage of 'print_preview'. A file path must be passed as 1st parameter."
        return
    fi
    local re='^[0-9]+$'
    if ! [[ $2 =~ $re ]]; then
        log "error" "Incorrect usage of 'print_preview'. A number must be passed as 2nd parameter."
        close
    fi

    eval 'head -$2 $1'
    if [ "$(wc -l <"$1")" -gt "$2" ]; then
        printf "\t\t%s" "(...)"
        echo
    fi
}

# Evaluates if Environment variable WORD_STATS_TOP is assigned
# If assigned then proceeds the normal execution
# Else warn pops up in console and a default is assigned by WORD_STATS_TOP_DEFAULT variable
word_stats_top_validate() {
    if string_empty "$WORD_STATS_TOP"; then

        # Tries to get environment variable one last time before default used
        if [ $1 == true ]; then
            WORD_STATS_TOP=$(env | grep WORD_STATS_TOP | grep -i -o '[0-9]*')
            word_stats_top_validate false
            return
        fi

        export WORD_STATS_TOP=$((WORD_STATS_TOP_DEFAULT))
        log "warn" "WORD_STATS_TOP: undefined (default: $WORD_STATS_TOP_DEFAULT)"
    else
        if is_number $WORD_STATS_TOP && ((WORD_STATS_TOP > 0)); then
            log "info" "WORD_STATS_TOP: $WORD_STATS_TOP"
        else
            log "warn" "WORD_STATS_TOP not valid ($WORD_STATS_TOP). Default used ($WORD_STATS_TOP_DEFAULT)"
            export WORD_STATS_TOP=$((WORD_STATS_TOP_DEFAULT))
        fi
    fi
}

# Processes the t_mode function into a png plot.
# If this function does not work it means you have changed the code and don't know what you're doing.
# Variables bellow must be correcly implemented as example
# GNU_PLOT_OUTPUT=".png"
# GNU_PLOT_OUTPUT_HTML=".html"
# MODE=$1   # ? 1st argument on user input when script called
# ISO=$3    # ? 3rd argument on user input when script called
# ORIGINAL_INPUT=$FILE
# OUTPUT_FILE="results/result---"
plot() {
    log "exec" "Creating plot..."
    # Defines path variables to working files
    GNU_PLOT_OUTPUT=$OUTPUT_FILE$GNU_PLOT_OUTPUT
    GNU_PLOT_OUTPUT_HTML=$OUTPUT_FILE$GNU_PLOT_OUTPUT_HTML

    local _max_y=$(cat $OUTPUT_FILE | head -1 | tr -s ' ' '\n' | tail -2 | head -1)
    _max_y=$((_max_y + 2))

    local _date="$(date +'%A %B %Y %H:%M')"

    local _authors=""
    # from https://stackoverflow.com/questions/9084257/bash-array-with-spaces-in-elements
    for ((i = 0; i < ${#AUTHORS[@]}; i++)); do
        _authors="$_authors${AUTHORS[$i]}; "
    done

    # Processes the gnuplot commands and assigns them to the temporary file
    local _stopwords=""
    if is_capital_letter $MODE; then
        _stopwords="No"
    else
        _stopwords="Yes ($ISO)"
    fi

    # if temporary file not exists one is created
    if ! file_exists GNU_PLOT_TEMP_FILE; then
        touch $GNU_PLOT_TEMP_FILE
    fi

    # Temporary file is emptied
    true >$GNU_PLOT_TEMP_FILE

    {
        echo "set title \"Top words for $ORIGINAL_INPUT\n$_date\nStopwords: $_stopwords\""
        echo "set term png size 800, 600"
        echo "set autoscale y"
        echo "set output \"$GNU_PLOT_OUTPUT\""

        echo "set boxwidth 0.6"
        echo "set style fill solid"
        echo "set xlabel \"Words\" font \"bold\""
        echo "set xtics rotate by -45"
        echo "set ylabel \"Quantity\" font \"bold\""
        # echo "set ytics 1"
        echo "set yrange [0:$_max_y]"
        echo "set grid ytics linestyle 1 linecolor rgb \"#e6e6e6\""
        echo "set key top"

        echo "set label 11 \"Authors: $_authors \nCreated: $(date +'%A %B %Y %H:%M')\" left at char 1, char 1.5 font \",10\""
        echo "set bmargin 8"

        echo "plot \"$OUTPUT_FILE\" using 1:2:xtic(3) with boxes title 'Occurrences' linecolor rgb \"#3399ff\", '' u 1:(\$2+0.1):2 with labels offset 0,0.5 title ''"
    } >"$GNU_PLOT_TEMP_FILE"

    # Creating the plot
    gnuplot <"$GNU_PLOT_TEMP_FILE"

    # Creating the html content for the html file (only presents image)
    {
        echo "<html>
        <div style=\"display: block; margin-left: auto; margin-right: auto; width: 40%; margin-top: 5%;\">
        <img src=\"./../$GNU_PLOT_OUTPUT\">
        </div>
        </html>"
    } >$GNU_PLOT_OUTPUT_HTML

    # Opens a new window in background with the created plot image
    echo
    log "info" "Opening preview..."
    # ! 'display' command not used because is not compatible with all SO's
    # ! Not compatible with WSL
    # Opened in background to let the script continue it's execution
    xdg-open $GNU_PLOT_OUTPUT >/dev/null 2>&1 &
    # display $GNU_PLOT_OUTPUT &
}

# Command pipe to remove and sort words from file
# If the first value is a 0 Stopwords are removed else all are used
# ? USAGE: query [0/1]
query() {
    local cmd="sort"
    if (($1 == 0)); then
        log "exec" "STOPWORDS FILTERED"
        # Saves command to filter the stopwords
        cmd="$cmd | grep -w -v -i -f $STOP_WORDS_FILE"
    else
        log "exec" "STOPWORDS IGNORED"
        # Saves command without the grep to ignore Stopwords
        # cmd="$cmd | "
    fi

    # Actual program. Yes... One line.
    # split_words $FILE | tr -d "'" | tr -d "$EXTRA_CHARS" | eval $cmd | uniq -c -i | sort -rn | cat -n | tr -d '\t' >$OUTPUT_FILE
    split_words $FILE | tr -d "'" | tr -d "$EXTRA_CHARS" | eval $cmd | awk NF | head -n -1 | uniq -c -i | sort -rn | cat -n | tr -d '\t' >$OUTPUT_FILE
}

# Processes the $FILE and outputs the result to $OUTPUT_FILE
# Uses the variables bellow as example
# STOP_WORDS_FILE="stop_words.txt"
# WORD_STATS_TOP=$(printenv WORD_STATS_TOP)
# FILE=$2   # ? 2rd argument on user input when script called
# EXTRA_CHARS='.,]:«}#/»=\;"(*<>)|?{•–[-'
# OUTPUT_FILE="results/result---"
c_mode() {
    # Checks what mode the user entered
    local cmd=""
    local lower=1
    if [ "$MODE" == "c" ]; then
        lower=0
    fi
    query lower

    # Results will be presented in a file
    # Prints PREVIEW_LENGHT to console
    echo
    echo "-------------------------------------"
    print_preview $OUTPUT_FILE $PREVIEW_LENGHT
    echo "-------------------------------------"
    echo
    log "exec" "RESULTS: $OUTPUT_FILE"
    log "exec"
    ls -lah $OUTPUT_FILE
    log "exec" "Distinct words: $(wc -l <$OUTPUT_FILE)"
}

# Processes the $FILE and outputs the result to $OUTPUT_FILE
# Top mode with WORD_STATS_TOP defined either environmentally or in script through WORD_STATS_TOP_DEFAULT
# Same variables as 'c_mode' used
t_mode() {
    # Checks what mode the user entered
    local cmd=""
    local lower=1
    if [ "$MODE" == "t" ]; then
        lower=0
    fi
    query lower

    # Results will be presented in a file
    # Prints PREVIEW_LENGHT to console
    local tmp_var=$(cat $OUTPUT_FILE)
    local dwords=$(wc -l <<<$tmp_var)
    sed -n 1,"$WORD_STATS_TOP"p <<<$tmp_var >$OUTPUT_FILE
    log "exec" "WORD_STATS_TOP = $WORD_STATS_TOP"

    echo
    echo "-------------------------------------"
    printf "\tTOP $WORD_STATS_TOP elements\n"
    print_preview $OUTPUT_FILE $WORD_STATS_TOP
    echo "-------------------------------------"
    echo
    log "exec" "RESULTS: $OUTPUT_FILE"
    log "exec"
    ls -lah $OUTPUT_FILE
    log "exec" "Distinct words: $dwords"

}

# Uses the 't_mode' and then processes the plot using the 'plot' function
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
    log "info" "Executing on mode '$MODE'."
else
    if string_empty $MODE; then
        log "error" "Mode required do execute [C/c|P/p|T/t]"
    else
        log "error" "Unknown mode '$MODE'"
    fi
    close
fi

# Check if file exists (and different than "") and the extension is allowed/supported
if string_empty "$FILE"; then
    log "error" "File not provided."
    close
else
    extension="${FILE##*.}"
    if index_in_array $extension in FILE_TYPES; then
        if file_exists FILE; then
            # get file extension
            log "info" "Opening '$FILE' as ${FILE_TYPES[${extension}]} file."
        else
            log "error" "File '$FILE' not found!"
            close
        fi
    else
        log "error" "File extension '$extension' not allowed."
        close
    fi
fi

# Check if ISO is suported, else use default "en"
if in_array ISO in ISOS; then
    log "info" "ISO format: '$ISO'."
else
    ISO="en"
    log "warn" "ISO not defined. Default will be used ('$ISO')."
fi

#
# ! If it reaches here means that
# !      ISO is correct and enabled in the ISOS array
# !      File exists and its type is supported
#

# Sets the STOP_WORDS_FILE path and checks its existance
# In case it doesn't exist, one is created empty and a warning pops up
STOP_WORDS_FILE="$LANG_PATH/$ISO.$STOP_WORDS_FILE"
if file_exists STOP_WORDS_FILE; then
    log "info" "Stop words file: $STOP_WORDS_FILE. ($(wc -l <$STOP_WORDS_FILE))"
else
    # Creates the ISO file
    touch $STOP_WORDS_FILE
    log "warn" "Stop words file not found ... creating empty"
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
    log "warn" "Output file will be overwritten: '$OUTPUT_FILE'"
    true >"$OUTPUT_FILE"
    touch "$OUTPUT_FILE"
else
    log "info" "Creating new output file: '$OUTPUT_FILE'"
    touch "$OUTPUT_FILE"
fi

# WORD_STATS_TOP validation
word_stats_top_validate 0

#
# ─────────────────────────────────────────────────────── COMPATIBILITY AREA ─────
#
# This area is used to convert different file formats into the default (txt)
# If this step is well written, then the following code will work without any change

# Converting PDF contents into Text
if string_equal "$extension" "pdf"; then
    touch $OUTPUT_TEMP
    pdftotext $FILE $OUTPUT_TEMP
    FILE=$OUTPUT_TEMP
fi

# Convert CRLF to LF EOL sequence to prevent bugs
touch $WORDS_LF
tr -d '\015' <$STOP_WORDS_FILE >$WORDS_LF
STOP_WORDS_FILE=$WORDS_LF

tr -d '\015' <$FILE >$FILE_LF
FILE=$FILE_LF

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
log "exec" "Processing '$ORIGINAL_INPUT'"

# Simple case for each one of the modes
case $MODE in

"c" | "C")
    log "exec" "COUNT MODE"
    c_mode
    ;;

"p" | "P")
    log "exec" "PLOT MODE"
    p_mode
    ;;
"t" | "T")
    log "exec" "TOP MODE"
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

# * Moved to function 'before_close'
# But use here your code whatever you like ;)

# Exiting the program
close

# ────────────────────────────────────────────────────────────────────────────────
