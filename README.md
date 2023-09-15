Blues is a simple shell script to find and delete stalled, not maintained by
packages files on FreeBSD. The files are deleted one by one, thus it is
possible to delete only selected ones. If you read this file on GitHub:
**please don't send pull requests here**. All will be automatically closed.
Any code propositions should go to the [Fossil](https://www.laeran.pl/repositories/beastcleaner) repository.

**WARNING:** The script is very simple and can produce false-positives results.
It is strongly recommended to create a backup or snapshot before you start
deleting files. Also, be sure to know what you are deleting. ;)

### Dependencies

To delete stalled files, you will need to run the script with root privileges.
They are not needed to just find the stalled files.

### Installation

Put the *beastcleaner.sh* script when anywhere it will be accessible by the
selected user.

### Configuration

Several options can be set in the script, mainly the paths and names of files
created by the script. These settings are optional, by default, the script
writes all files to */tmp* directory. If you want to change it, please open
the script with your favorite text editor and read the first lines of it,
where the configuration section is. There is everything explained.

### Usage

* To find only the stalled files, run the script without any arguments. For
  example: `./beastcleaner.sh`. It will print the list via `less` command.
* If you want to delete stalled files, you have to run the script as root
  user with argument **clean**. For example: `sudo ./beastcleaner.sh clean`.
  You will need to confirm each deletion of a file from the list.

### License

The project is released under 3-Clause BSD license.

---
That's all for now, as usual, I have probably forgotten about something important ;)

Bartek thindil Jasicki
