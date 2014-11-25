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
TMP_FILE=/tmp/temporary_gist_file
PARSE_FILE=/tmp/temporary_gist_parsing_file
cleanup (){
    rm ${TMP_FILE} &> /dev/null
    rm ${PARSE_FILE} &> /dev/null
}
trap cleanup EXIT

# Check all the flags, have plans to add in a verbose and quiet flag, but not yet
while getopts "f:n:c:u:d:p" flag; do
    case ${flag} in
	f)
	    if [ ! -f ${OPTARG} ]; then
		echo "${OPTARG} does not exist. Please specify an existing filename"
		exit 1
	    else
		# Strip everything but the filename (/usr/test.txt -> test.txt)
		FILENAME="\"$(basename ${OPTARG})\""

		# Escape newlines and double-quotes and backslashes
		# for smooth JSON parsing
		# (Github's Gist API only accepts JSON requests)
	        cat ${OPTARG} | sed -e 's/\\/\\\\/g' > ${PARSE_FILE}
		CONTENT=$(awk '{print $0"\\n"}' ${PARSE_FILE})
		CONTENT="\"$(echo ${CONTENT} | awk '{gsub(/"/, "\\\"")} 1')\""
	    fi
	    ;;
	n)
            # We expect the user to provide his own newlines, but we can escape
            # double-quotes for him
            FILENAME="\"$(echo ${OPTARG} | awk '{gsub(/"/, "\\\"")} 1')\""
	    ;;
	c)
            # Again escaping double-quotes
            CONTENT="\"$(echo ${OPTARG} | awk '{gsub(/"/, "\\\"")} 1')\""
	    ;;
	u)
	    USER="--user ${OPTARG}"
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
						     
# This is the formatting of the JSON request as per the Github Gist API
echo "{${DESCRIPTION}\"public\": ${PUBLIC}, \"files\": {${FILENAME}: {\"content\": ${CONTENT}}}}" > ${TMP_FILE}


# This line has a lot going for it. We send the curl request, with
# user-authentication if requested, and set up the POST request.
# We process the response HTML and print the URL of the gist to the user
curl --silent ${USER} -X POST -H 'Content-Type: application/json' -d @${TMP_FILE} https://api.github.com/gists | grep "html_url" | head -n 1 | awk '{gsub(/^ +/, "")} 1'

# If we could not find the html_url in the response, then we have to tell the
# user that the http request failed and that his/her gist was not posted
if [ ${PIPESTATUS[1]} -ne 0 ]; then
       echo "ERROR: gist failed to post, script exiting..."
       exit 1
   fi
