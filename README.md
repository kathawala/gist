Bash script which allows you to post a text file as a Github Gist

USAGE
=====

Allows you to post a text file as a gist under any username or anonymously. Takes in a file as an argument, the contents of which are posted as the gist to github. User can specify other options to change the name, description, visibility, etc of the gist. Called without arguments, the script prints out a help message.

FLAGS
=====

-n    Specify the name of the gist you'd like to create

-u    Specify the user (default is anonymous)

-d    Add a description for the gist

-p    Specify the creation of a private (aka "secret") gist. The default is public.

EXAMPLES
========

Create a public gist under your username using an existing text file

> `gist.sh -u "exampleuser" test.txt`

Create an anonymous gist with a name different from the name of the file containing the content to be gisted.

> `gist.sh -n "fun_program" test.txt`

Create a private gist under your username with a description attached

> `gist.sh -p -u "exampleuser" -d "A mind-blowing text file!" test.txt`

OUTPUT
======

Return value is the URL of the gist you have just posted.


FEATURES TO COME
================

I would love to implement the following things. If you have an idea or think it'd be easy to do,
please contribute!!!

1)  Processing multiple arguments
2)  Options for output (quiet with no url output, url output to the clipboard, etc)
3)  1-time user authentication (currently if a user is specified, password must be given each time)

CONTACT
=======

Please make issues for any features you'd like to see or bugs! Hope you enjoy!
