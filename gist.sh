#!/bin/bash
# A bash script meant to take in user input, craft an API call to Github's Gist
# API and send the request, with content and filename filled in by the user

#Sends error on script failure
set -o errexit

USER=
FILENAME=
CONTENT=
DESCRIPTION=
PUBLIC="true"

# This function takes a file as input argument and creates a valid
# JSON string which is then set as the value of the variable CONTENT.
# The sed call escapes backslashes and double quotes and places
# literal newlines and literal tab characters (\n\t) where newlines and
# tabs originally were in the text.
function format_file_as_JSON_string() {
    sed -e 's/\\/\\\\/g' \
	-e 's/$/\\n/g' \
	-e 's/"/\\"/g' \
	-e 's/\t/\\t/g' \
	| tr -d "\n"
}


# Check all the flags, have plans to add in a verbose and quiet flag, but not yet
while getopts "n:u:d:p" flag; do
    case ${flag} in	    
	n)
            # We expect the user to provide his own newlines, but we can escape
            # double-quotes for him
            FILENAME="\"$(echo ${OPTARG} | awk '{gsub(/"/, "\\\"")} 1')\""
	    ;;
	u)
	    USER="-u${OPTARG}"
	    ;;
	d)
            # Again escaping double-quotes
            # Description variable also includes the JSON syntax of 
            # "description": "argument" so that if a description is not specified
            # we can still send the gist
	    DESCRIPTION="\"description\": \"$(echo ${OPTARG} | awk '{gsub(/"/, "\\\"")} 1')\", "
	    ;;
	p)
	    PUBLIC="false"
	    ;;
	*)
	    exit 1
	    ;;
	    
    esac
done

# Check if we have no arguments, and if so, print the help message
shift $((OPTIND - 1))
if [ $# -eq 0 ]; then
    cat <<EOF
    
    usage:  gist [-options] arg1
    
    options:
        -n   Specify the name of your gist
        -u   Specify the user (default is anonymous)
        -d   Specify a description for your gist
        -p   Specify the creation of a private (aka "secret" gist.
    
    Report bugs to: farhank@stanford.edu
    pkg home page:  <https://github.com/kathawala/gist/blob/master/gist.sh>
EOF

    exit 1
fi

# If we are here we must have an argument, so we go ahead and process
# the file given into valid JSON.
FILE=${1}
if [ ! -f "${FILE}" ]; then
    echo "${FILE} does not exist. Please specify an existing filename"
    exit 1
else
    # Strip everything but the filename (/usr/test.txt -> test.txt)
    if [ -z "${FILENAME}" ]; then
        FILENAME="\"$(basename "${FILE}")\""
    fi
    CONTENT="\"$(format_file_as_JSON_string < "${FILE}")\""
fi
						     
# This is the formatting of the JSON request as per the Github Gist API
#{
#  "description": "the description for this gist",
#  "public": true,
#  "files": {
#    "file1.txt": {
#      "content": "String file contents"
#    }
#  }
#}
# This pipeline has a lot going for it. We format the gist as described above
# send the curl request, with user-authentication if requested, and set up the
# POST request. We process the response HTML and print the gist's URL to the user
echo "{${DESCRIPTION}\"public\": ${PUBLIC}, \"files\": {${FILENAME}: {\"content\": ${CONTENT}}}}" \
    | curl --silent "${USER}" -X POST -H 'Content-Type: application/json' -d @- https://api.github.com/gists \
    | grep "html_url" \
    | head -n 1 \
    | sed '{;s/"//g;s/,$//;s/\s\shtml_url/URL/;}'

# If we could not find the html_url in the response, then we have to tell the
# user that the http request failed and that his/her gist was not posted
if [ ${PIPESTATUS[2]} -ne 0 ]; then
    echo "ERROR: gist failed to post, script exiting..."
    exit 1
fi
