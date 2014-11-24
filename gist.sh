#!/bin/bash
#A bash script meant to take in user input, craft an API call to Github's Gist
#API and send the request, with content and filename filled in by the user

#Sends error on script failure
set -o errexit

USER=
FILENAME=
CONTENT=

# We will send this file in the curl POST request, it gets removed when we finish
TMP_FILE=/tmp/temporary_gist_file
trap "rm ${TMP_FILE} &> /dev/null" EXIT

# Check all the flags, have plans to add in a verbose and quiet flag, but not yet
while getopts "f:n:c:u:" flag; do
    case ${flag} in
	f)
	    if [ ! -f ${OPTARG} ]; then
		echo "${OPTARG} does not exist. Please specify an existing filename"
		exit 1
	    else
		# Strip everything but the filename (/usr/test.txt -> test.txt)
		FILENAME="\"$(basename ${OPTARG})\""

		# Escape newlines and double-quotes for smooth JSON parsing
		# (Github's Gist API only accepts JSON requests)
		CONTENT=$(awk '{print $0"\\n"}' ${OPTARG})
		CONTENT="\"$(echo ${CONTENT} | awk '{gsub(/"/, "\\\"")} 1')\""
	    fi
	    ;;
	n)
	    FILENAME="\"${OPTARG}\""
	    ;;
	c)
            #We expect the user to provide his/her own newlines, but we can escape
            #double-quotes for him/her
            CONTENT="\"$(echo ${OPTARG} | awk '{gsub(/"/, "\\\"")} 1')\""
	    ;;
	u)
	    USER="--user ${OPTARG}"
	    ;;
	*)
	    exit 1
	    ;;
	    
    esac
done
						     
# This is the formatting of the JSON request as per the Github Gist API
echo "{\"files\": {${FILENAME}: {\"content\": ${CONTENT}}}}" > ${TMP_FILE}

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
