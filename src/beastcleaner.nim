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

import std/[os, parseopt]
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
      -h, --help    - Show this help and quit
      -v, --version - Show the program version info

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
      Beastcleaner version: 0.1.0

      Copyright: 2024 Bartek Jasicki <thindil@laeran.pl.eu.org>
      License: 3-Clause BSD""")
      stdout.flushFile
    except IOError:
      when isMainModule:
        quit QuitFailure
    when isMainModule:
      quit QuitSuccess


proc main() {.raises: [], tags: [ReadIOEffect, WriteIOEffect], contractual.} =
  ## The main procedure of the program
  var options: OptParser = initOptParser(shortNoVal = {'h', 'v'}, longNoVal = @[
        "help", "version"])
  type Setting = string
  const
    awkScript: Setting = "/tmp/beastcleaner.awk"
    pkgList: Setting = "/tmp/list1.txt"
    filesList: Setting = "/tmp/list2.txt"
    filesDiff: Setting = "/tmp/beastdiff.txt"

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
      else:
        quit "Unknown option '" & options.key & "'. To see all available options, run the program with --help."
    of cmdArgument:
      case options.key:
      of "clean":
        if not isAdmin():
          quit "To clean the system, please run the program as root, via su, sudo, dosu, etc."
      else:
        quit "Unknown argument '" & options.key & "'. To see all available arguments, run the program with --help."

main()
