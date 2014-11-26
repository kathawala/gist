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

# These files get removed on exit, still looking for ways to omit them altogether
JSON_FILE=/tmp/temporary_gist_json_file.json
PARSE_FILE=/tmp/temporary_gist_parsing_file
TMP=/tmp/temporary_gist_parsing_file.temp
cleanup (){
    rm ${JSON_FILE} &> /dev/null
    rm ${PARSE_FILE} &> /dev/null
    rm ${TMP} &> /dev/null
}
trap cleanup EXIT

# This function takes a file as input argument and creates a valid
# JSON string which is then set as the value of the variable CONTENT.
# The sed and awk calls escape backslashes and double quotes and place
# literal newlines and literal tab characters (\n\t) where newlines and
# tabs originally were in the text.
function format_file_as_JSON_string() {
    sed -e 's/\\/\\\\/g' < ${1} > ${PARSE_FILE}
    awk '{print $0"\\n"}' ${PARSE_FILE} > ${TMP} && mv ${TMP} ${PARSE_FILE}
    awk '{gsub(/"/, "\\\"")} 1' < ${PARSE_FILE} > ${TMP} && mv ${TMP} ${PARSE_FILE}
    sed 's/\t/\\t/g' < ${PARSE_FILE} > ${TMP} && mv ${TMP} ${PARSE_FILE}
    cat /dev/null > ${TMP}

    # This block encloses the file in double quotes and strips away all newlines
    # so a file which looks like:
    #    Hi\n
    #      Indentation\n
    #        More!\n
    # would become a valid JSON string:
    #    "Hi\n  Indentation\n    More!\n"
    echo -n "\"" >> ${TMP}
    IFS=''
    while read -r data; do
	line="$data"
	echo -n "$line" >> ${TMP}
    done < ${PARSE_FILE}
    echo -n "\"" >> ${TMP} && mv ${TMP} ${PARSE_FILE}
    
    CONTENT=$(cat ${PARSE_FILE})
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
if [ ! -f ${FILE} ]; then
    echo "${FILE} does not exist. Please specify an existing filename"
    exit 1
else
    # Strip everything but the filename (/usr/test.txt -> test.txt)
    if [ -z ${FILENAME} ]; then
        FILENAME="\"$(basename ${FILE})\""
    fi
    format_file_as_JSON_string ${FILE}
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
echo "{${DESCRIPTION}\"public\": ${PUBLIC}, \"files\": {${FILENAME}: {\"content\": ${CONTENT}}}}" > ${JSON_FILE}


# This line has a lot going for it. We send the curl request, with
# user-authentication if requested, and set up the POST request.
# We process the response HTML and print the URL of the gist to the user
curl --silent ${USER} -X POST -H 'Content-Type: application/json' -d @${JSON_FILE} https://api.github.com/gists | grep "html_url" | head -n 1 | awk '{gsub(/^ +/, "")} 1'

# If we could not find the html_url in the response, then we have to tell the
# user that the http request failed and that his/her gist was not posted
if [ ${PIPESTATUS[1]} -ne 0 ]; then
       echo "ERROR: gist failed to post, script exiting..."
       exit 1
   fi

