# epitools package

Here is an atom package for epitech's students.

His main goal is to handle all the special things that you need for C programming in epitech with atom :

* headers generator and updater
* indentation (a mix between tabs and space, like emacs)

He could also implement some usefull behaviour :

* automatically turn-on when a headers is detect in the file, or when you insert one
* check/correct indentation on save, open...
* suggest a project name for the headers based on the others sources files in the project


* linter for the epitech's C standard, especially for invisible typo like space at the end of a line
* Makefile generator and updater
* blih management (save time and never forget ramassage-tek again)
* intranet acces within atom (for the timetable or the module list for example)

If you have some ideas, feel free to open an issue.

And don't forget : this is atom ! There is already thousand of packages, and this one only aim to supports epitech's specific requirement. So don't ask for a git support, an interface to gcc or a generic C linter, there is already packages for that out there.

For now, there is no very mutch to see. but I espect to make something basic before january.

## TODO list
#### Core
* detect TextEditor change : OK
* detect Grammar change : OK
* icon show up in staus bar : OK
* manual activation : OK
* auto activation when detect header : OK
* Hide when not in C file or Makefile : OK

#### Header
* Insert on top : OK
* Insert on cursor : OK
* Config user info : OK
* prevent modification of header on save : OK
* Update header on save : OK
* Detect project name
* Ask project name : OK
* detect header : OK

#### Indentaion
* correctly config the pane when actiavte (SoftTab, 2 spaces)
* catch change in the Tab config (notification or cancel)
* backup config to restore when turnOff
* convert eight space to one tab on when modifiyng a line
* Full check on save

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
