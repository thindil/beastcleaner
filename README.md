Beast cleaner is a simple console program to find and delete stalled,
not maintained by packages files on FreeBSD. The files are deleted one by
one, thus it is possible to delete only selected ones. If you read this file
on GitHub: **please don't send pull requests here**. All will be automatically
closed. Any code propositions should go to the [Fossil](https://www.laeran.pl.eu.org/repositories/beastcleaner)
repository.

**WARNING:** The program is very simple and can produce false-positives results.
It is strongly recommended to create a backup or snapshot before you start
deleting files. Also, be sure to know what you are deleting. ;)

### Running dependencies

To delete stalled files, you will need to run the program with root privileges.
They are not needed to just find the stalled files.

### How to install

#### Precompiled packages

There are available binary packages for the newest stable FreeBSD 64-bit on the
download page. If you want to use Nish on different version or architecture,
you have to build it from the source.

#### Build from the source

You will need:

* [Nim compiler](https://nim-lang.org/install.html)
* [Contracts](https://github.com/Udiknedormin/NimContracts)
* [Nimalyzer](https://github.com/thindil/nimalyzer)
* [Unittests2](https://github.com/status-im/nim-unittest2)

You can install them manually or by using [Nimble](https://github.com/nim-lang/nimble).
In that second option, type `nimble install https://github.com/thindil/beastcleaner` to
install the program and all dependencies. Generally it is recommended to use
`nimble release` to build the project in release (optimized) mode or
`nimble debug` to build it in the debug mode.

To install *nimble* on FreeBSD, type: `pkg install nimble`.

### Usage

* To find only the stalled files, run the program without any arguments. For
  example: `./beastcleaner`. It will print the list via `less` command.
* If you want to delete stalled files, you have to run the program as root
  user with argument **clean**. For example: `sudo ./beastcleaner clean`.
  You will need to confirm each deletion of a file from the list.
* You can set the location of the file with the list of stalled files by adding
  option `--fileslist` to the program, for example:
  `./beastcleaner --fileslist=thelist.txt`.
* If you provide the file with the list of stalled files when deleting the
  stalled files, via `--fileslist` option, it will be used instead of
  generating the new one.

### License

The project is released under 3-Clause BSD license.

---
That's all for now, as usual, I have probably forgotten about something important ;)

Bartek thindil Jasicki
