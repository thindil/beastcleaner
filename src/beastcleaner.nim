# Copyright © 2024 Bartek Jasicki
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

## The main module of the program.

import std/[algorithm, os, osproc, parseopt, sets, strutils, terminal]
import contracts

proc showCommandLineHelp() {.sideEffect, raises: [], tags: [WriteIOEffect],
    contractual.} =
  ## Show the program arguments help
  ##
  ## Return QuitSuccess when the program's arguments help was shown, otherwise
  ## QuitFailure.
  body:
    try:
      stdout.writeLine(x = """Available options are:
      -h, --help      - Show this help and quit
      -v, --version   - Show the program version info
      -f, --fileslist - The file to which the list of not managed files will be written

Available arguments are:
      clean         - Clean interactively the system""")
      stdout.flushFile
    except IOError:
      when isMainModule:
        quit QuitFailure
    when isMainModule:
      quit QuitSuccess

proc showProgramVersion() {.sideEffect, raises: [], tags: [WriteIOEffect],
    contractual.} =
  ## Show the program version
  ##
  ## Returns QuitSuccess when the program's arguments help was shown, otherwise
  ## QuitFailure.
  body:
    try:
      stdout.writeLine(x = """
      Beastcleaner version: 0.0.1

      Copyright: 2024 Bartek Jasicki <thindil@laeran.pl.eu.org>
      License: 3-Clause BSD""")
      stdout.flushFile
    except IOError:
      when isMainModule:
        quit QuitFailure
    when isMainModule:
      quit QuitSuccess


proc main() {.raises: [], tags: [ReadIOEffect, WriteIOEffect, ExecIOEffect,
    RootEffect], contractual.} =
  ## The main procedure of the program
  var options: OptParser = initOptParser(shortNoVal = {'h', 'v'}, longNoVal = @[
        "help", "version"])
  type
    Setting = string
    Actions = enum
      show, clean
  var filesDiff: Setting = "/tmp/beastdiff.txt"
  var action: Actions = show

  # Check the program's arguments and options
  while true:
    options.next
    case options.kind
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      case options.key
      of "h", "help":
        showCommandLineHelp()
      of "v", "version":
        showProgramVersion()
      of "f", "fileslist":
        filesDiff = options.val
      else:
        quit "Unknown option '" & options.key & "'. To see all available options, run the program with --help."
    of cmdArgument:
      case options.key:
      of "clean":
        if not isAdmin():
          quit "To clean the system, please run the program as root, via su, sudo, dosu, etc."
        action = clean
      else:
        quit "Unknown argument '" & options.key & "'. To see all available arguments, run the program with --help."

  # Get the list of all files installed by all packages
  try:
    stdout.write(s = "Generating the list of all files installed by all packages ... ")
    stdout.flushFile
  except IOError:
    quit "Can't show message."
  var (output, exitCode) = try:
      execCmdEx(command = "pkg info --list-files -a")
    except OSError, IOError:
      quit "Can't execute pkg command"
  if exitCode != 0:
    quit "Can't get the list of all files installed by packages."
  output.stripLineEnd
  let files: seq[string] = output.splitLines
  var managedFiles: HashSet[string] = initHashSet[string]()
  for file in files:
    if file.endsWith(suffix = ':'):
      continue
    try:
      managedFiles.incl(key = file.strip)
    except Exception:
      quit "Can't count the filename hash."
  echo "done."

  # Get the list of all files
  try:
    write(f = stdout, s = "Generating the list of all files in /usr/local ... ")
    stdout.flushFile
  except IOError:
    quit "Can't show message."
  var installedFiles: HashSet[string] = initHashSet[string]()
  try:
    for entry in walkDirRec(dir = "/usr/local", yieldFilter = {pcFile,
        pcLinkToFile}):
      installedFiles.incl(key = entry)
  except OSError:
    quit "Can't create the list of all local files."
  echo "done."

  # Save the difference to the file
  try:
    write(f = stdout, s = "Creating the list of files not managed by packages ... ")
    stdout.flushFile
  except IOError:
    quit "Can't show message."
  let diffFile: File = try:
      open(filename = filesDiff, mode = fmWrite)
    except IOError:
      quit "Can't create the output file."
  installedFiles = installedFiles - managedFiles
  var diffFiles: seq[string] = @[]
  for file in installedFiles:
    diffFiles.add(y = file)
  diffFiles.sort(cmp = system.cmp)
  for file in diffFiles:
    try:
      diffFile.writeLine(x = file)
    except IOError:
      quit "Can't save non-managed file to output file."
  diffFile.close
  echo "done."

  if action == show:
    try:
      if execCmd(command = "less " & filesDiff) != 0:
        quit QuitFailure
    except IOError:
      quit "Can't show the list of files not managed by packages. Reason: " &
          getCurrentExceptionMsg()
  else:
    try:
      var answer: char = 'n'
      for line in filesDiff.lines:
        if answer != 'a':
          write(f = stdout, s = "Delete file '" & line & "'? ([Y]es/[N]o/[A]ll/[C]ancel)")
          answer = getch().toLowerAscii
        if answer == 'c':
          break
        if answer in ['y', 'a']:
          removeFile(file = line)
    except IOError, OSError:
      echo "Can't remove files. Reason: " & getCurrentExceptionMsg()

main()
