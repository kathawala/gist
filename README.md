Bash script which allows you to post a text file as a Github Gist

USAGE
=====

Allows you to post a text file as a gist under any username or anonymously. The user can specify a text file or the user can specify a name for the gist and write the contents in at the command line.

FLAGS
=====

-f    Specify a filename of an existing file to send as a gist.

-n    Specify the name of a gist you'd like to create (must be used in conjunction with -c)

-c    Specify the text of the gist you'd like to create (must be used in conjunction with -n)

-u    Specify the user (makes the gist private)

EXAMPLES
========

Create a gist under your username using an existing text file

> `gist.sh -u exampleuser -f test.txt`

Create an anonymous gist specifying gist name and text contents at command line (newlines need to be specified using '\n' character).

> `gist.sh -n test -c "This is a test\nPlease ignore"`

OUTPUT
======

Return value is the URL of the gist you have just posted.

CONTACT
=======

Please make issues for any features you'd like to see or bugs! Hope you enjoy!
