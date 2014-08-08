## Time Machine Browser for linux

#### Note:

I found out "too late" that this problem has already been solved in Ubuntu, and I'd bet it has in other linux distros as well. I went ahead with the project though as a way of familiarizing myself with lisp. At best, your distro has a built-in function for it, at worst you can use this instead. If you use ubuntu, see [this page](http://manpages.ubuntu.com/manpages/saucy/man1/tmfs.1.html).

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
