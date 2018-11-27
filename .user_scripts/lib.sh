# General library functions that can be sourced and used anywhere
# Sourcing into a different script can be done with
# . ~/.user_scripts/lib.sh
# which will load all the functions into your script or session


######################################
# Log something to stdout with a datestamp prefix
# Arguments:
#   $1 => Message to log
######################################
function consoleLog {
    echo '['$(date +'%a %Y-%m-%d %H:%M:%S %z')']' "$1"
}

######################################
# Generate a random password from /dev/urandom
# pw [length [num_passwords [characters]]
# Arguments:
#   $1 => The length of password
#   $2 => The number of passwords to generate
#   $3 => The acceptable character set, PCRE regex
######################################
function pw {
    if [[ "x$1" == "x-h" ]]; then
        echo "Usage: pw [length:20 [num_passwords:1 [character_set:a-zA-Z0-9._!@#$%^&*()]]]"
    else
        LC_CTYPE=C \
            tr -dc "${3:-'a-zA-Z0-9._!@#$%^&*()'}" < /dev/urandom \
            | fold -w "${1:-20}" \
            | head -n "${2:-1}"
    fi
    # There's always `openssl rand -base64 12` for simplicity
}

