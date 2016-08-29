## Time Machine Browser for linux

#### Note:

I found out "too late" that this problem has already been solved using a FUSE [called tmfs](http://manpages.ubuntu.com/manpages/saucy/man1/tmfs.1.html). Unfortunately, it dosen't seem to work correctly for folder references that are inside other folder references. In any case, I created my own FUSE to solve this problem, which obsoletes this repo. You can find it here: https://github.com/kanatzidis/Wells

### Setup

The script will run in clisp and probably most or all other common lisp implementations, and will run as-is in sbcl. To install sbcl use either MacPorts or Homebrew:

`brew install sbcl`

`sudo port install sbcl`

#### Optional - Compile an executable:

To compile an executable version, run:

`sbcl --load main.lisp --eval "(sb-ext:save-lisp-and-die \"tm-browser\" :toplevel #'main :executable t)"`

The executable will be large but *should* (maybe) run on your architecture without a lisp installation. It could even be faster! Who knows, I didn't do any optimizations.

### Usage

Load the program however makes you the happiest. It will ask you for the absolute path to your Time Machine hard drive. After that you can use cd and ls (without additional arguments, yet at least) as you normally would on the command line.

You can get files by using `cp filename destination`.
