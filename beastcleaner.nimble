import os

# Package

version = "0.1.0"
author = "Bartek thindil Jasicki"
description = "A simple program to check and remove unmaintaned files on FreeBSD"
license = "BSD-3-Clause"
srcDir = "src"
bin = @["beastcleaner"]
binDir = "bin"


# Dependencies

requires "nim >= 2.2.0"
requires "contracts >= 0.2.2"
requires "nimalyzer >= 0.11.0"
requires "unittest2"

# Tasks

task debug, "builds the project in debug mode":
  exec "nim c -d:debug --styleCheck:hint --spellSuggest:auto --errorMax:0 --outdir:" &
      binDir & " " & srcDir & DirSep & "beastcleaner.nim"

task release, "builds the project in release mode":
  exec "nim c -d:release --passC:-flto --passL:-s --outdir:" & binDir & " " &
      srcDir & DirSep & "beastcleaner.nim"

task test, "run the project unit tests":
  for file in listFiles("tests"):
    if file.endsWith("nim"):
      exec "nim c --verbosity:0 -r " & file

task analyze, "builds the project in analyze mode (release with nimprofiler support)":
  exec "nim c -d:release --profiler:on --stackTrace:on --passC:-flto --passL:-s --outdir:" & binDir & " " &
      srcDir & DirSep & "beastcleaner.nim"
