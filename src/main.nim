import os
import tables
import strformat
import sequtils
import unicode
import options
import terminal
import parseopt
import times
import re

from icons import Icons

var directory: string

let
    red = "\e[31m"
    yellow = "\e[33m"
    cyan = "\e[36m"
    green = "\e[32m"
    blue = "\e[34m"
    def = "\e[0m"

var showHidden    = false        # -a
var showList      = false        # -l
var showMeta      = false        # -m
var showDirsOnly  = false        # -d
var showFilesOnly = false        # -f

proc parseCommandLineArgs() =
  var p = initOptParser(commandLineParams())

  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case p.key:
      of "a": showHidden    = true
      of "l": showList      = true
      of "m":
        showMeta = true
        showList = true
      of "d": showDirsOnly  = true
      of "f": showFilesOnly = true
    of cmdArgument:
      directory = p.key

proc isDirectory(path: string): bool =
  return path.dirExists()

proc isFile(path: string): bool =
  return path.fileExists()

proc isExecutable(path: string): bool =
  var permissions = path.getFilePermissions()
  return permissions.contains(fpUserExec) and path.isFile()

proc alignLeftWithANSISequences(s: string): string =
  let escaped: string = s.replace(re(r"(\\e\[[0-9]+m)"), "1")
  echo escaped
  echo escaped.len()

proc getPermissionString(info: FileInfo): string =
  result &= (if info.kind == pcDir: "{blue}d{def}".fmt() else: ".")

  if info.permissions.contains(fpUserRead): result &= "{green}r{def}".fmt() else: result &= "-"
  if info.permissions.contains(fpUserWrite): result &= "{yellow}w{def}".fmt() else: result &= "-"
  if info.permissions.contains(fpUserExec): result &= "{red}x{def}".fmt() else: result &= "-"

  if info.permissions.contains(fpGroupRead): result &= "{green}r{def}".fmt() else: result &= "-"
  if info.permissions.contains(fpGroupWrite): result &= "{yellow}w{def}".fmt() else: result &= "-"
  if info.permissions.contains(fpGroupExec): result &= "{red}x{def}".fmt() else: result &= "-"

  if info.permissions.contains(fpOthersRead): result &= "{green}r{def}".fmt() else: result &= "-"
  if info.permissions.contains(fpOthersWrite): result &= "{yellow}w{def}".fmt() else: result &= "-"
  if info.permissions.contains(fpOthersExec): result &= "{red}x{def}".fmt() else: result &= "-"


proc processEntry(path: string): Option[string] =
  var entryParts = splitFile(path)
  var icon: string
  var entry: string

  if not showHidden:
    if entryParts.name[0] == '.': return none(string)

  if showDirsOnly:
    if path.isFile(): return none(string)

  if showFilesOnly:
    if path.isDirectory(): return none(string)

  if path.isFile():
    icon = Icons["ext"].getOrDefault(entryParts.ext, Icons["other"]["plainFile"])
    entry = "{icon} {entryParts.name}{entryParts.ext}".fmt()
  elif path.isDirectory():
    icon = Icons["directories"].getOrDefault(entryParts.name, Icons["other"]["directory"])
    entry = "{blue}{icon} {entryParts.name}{entryParts.ext}{def}".fmt()
  
  if path.isExecutable():
    if icon == Icons["other"]["plainFile"]:
      icon = Icons["other"]["executable"]
    entry = "{green}{icon} {entryParts.name}{entryParts.ext}{def}".fmt()

  if showMeta:
    let info = path.getFileInfo()
    let lastUpdated = path.getLastModificationTime().format("ddd MMM dd hh:mm:ss YYYY")
    let entrySize = align("{path.getFileSize()} B".fmt(), 8)

    let entryPermissions = getPermissionString(info)

    return some("{entryPermissions} {yellow}{entrySize}{def} {green}{lastUpdated}{def} {entry}".fmt())

  return some(entry)

if isMainModule:
  parseCommandLineArgs()

  if directory == "":
    directory = os.getCurrentDir()

  var entries: seq[string] = @[]

  for entry in os.walkDir(directory):
    var processed = processEntry(entry.path)
    if processed.isSome:
      entries.add(processed.get())

  if entries.len() != 0:
    let maxWordLength = entries.mapIt(it.len()).max()
    let maxWordsPerLine = terminalWidth() div (maxWordLength + 2)

    for i in 0 ..< entries.len():
      echo alignLeftWithANSISequences(entries[i])
      if not showList:
        stdout.write(alignLeft(entries[i], maxWordLength + 2))
        if (i + 1) mod maxWordsPerLine == 0:
          echo ""
      else:
        stdout.writeLine(entries[i])

    if not showList: echo ""
