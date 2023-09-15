#!/bin/sh
# Copyright © 2023 Bartek Jasicki
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#################
# Configuration #
#################
# The full path to the file which will be used to find the installed and
# managed files.
awk_script="/tmp/beastcleaner.awk"
# The full path to the file with the list of installed and managed by packages
# files.
pkg_list="/tmp/list1.txt"
# The full path to the list of all files which are in /usr/local directory.
files_list="/tmp/list2.txt"
# The full path to the file with the list of files wchich are in /usr/local
# directory, but not managed by packages.
files_diff="/tmp/beastdiff.txt"

# Show the help and exit.
if [ "$1" = "help" ]; then
   echo 'Possible arguments:
   * help  - show the help sceen and quit
   * clean - clean interactively the system
   To list files to delete, run the script without arguments.'
   exit
fi

# The user entered unknown option, show the available ones and exit.
if [ "$#" -gt 0 ] && [ "$1" != "help" ] && [ "$1" != "clean" ]; then
   echo "Unknown argument. To see available options, run the script with help argument."
   exit 1
fi

# If the script is set to clean action, check if we have proper privileges to do it.
if  [ "$#" -gt 0 ] && [ "$1" = "clean" ] && [ "$(id -u)" != "0" ]; then
   echo "To clean the system, please run the script as root, via su, sudo, dosu, etc."
   exit 1
fi

#######################################
# Prepare the list of files to delete #
#######################################
# Create awk file if doesn't exist
if [ ! -f "$awk_script" ]; then
   echo '$1 ~ /\/usr\/local\// {c=index($1,":");if(c==0){for(i=1;i<NF;i++){printf "%s ",$i}printf "%s\n",$i}}' > "$awk_script"
fi
# Get the list of all files installed by all packages
printf "Generating the list of all files installed by all packages ... "
pkg info --list-files -a | awk -f "$awk_script" | sort > "$pkg_list"
echo "done."
# Get the list of all files
printf "Generating the list of all files in /usr/local ... "
find -x /usr/local -type f -or -type l 2>/dev/null | sort > "$files_list"
echo "done."
# Save the difference to the file
printf "Creating the list of files not managed by packages ... "
diff "$pkg_list" "$files_list" | grep '^>' | cut -d" " -f2- > "$files_diff"
echo "done."

###########
# Actions #
###########
# Show the difference, if user didn't set any argument
if [ "$#" -lt 1 ]; then
   less "$files_diff"
# Delete the files. The user will be asked for deletion of each file
elif [ "$1" = "clean" ]; then
   while IFS= read <&3 -r i; do
      rm -i -- "$i"
   done 3< "$files_diff"
fi
