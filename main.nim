import os
import tables
import strformat
import sequtils
import unicode
import options
import terminal
import parseopt
from icons import Icons

type Entry = (ForegroundColor, string)

var directory: string

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
      of "m": showMeta      = true
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

proc processEntry(path: string): Option[Entry] =
  var entryParts = splitFile(path)
  var icon: string
  var color: ForegroundColor

  if not showHidden:
    if entryParts.name[0] == '.': return none(Entry)

  if showDirsOnly:
    if path.isFile(): return none(Entry)

  if showFilesOnly:
    if path.isDirectory(): return none(Entry)

  if path.isFile():
    color = fgDefault
    icon = Icons["ext"].getOrDefault(entryParts.ext, Icons["other"]["plainFile"])
  elif path.isDirectory():
    color = fgBlue
    icon = Icons["directories"].getOrDefault(entryParts.name, Icons["other"]["directory"])
  
  if path.isExecutable():
    color = fgGreen
    if icon == Icons["other"]["plainFile"]:
      icon = Icons["other"]["executable"]

  return some((color, "{icon} {entryParts.name}{entryParts.ext}".fmt()))

if isMainModule:
  parseCommandLineArgs()

  if directory == "":
    directory = os.getCurrentDir()

  var entries: seq[Entry] = @[];

  for entry in os.walkDir(directory):
    var processed = processEntry(entry.path)
    if processed.isSome:
      entries.add(processed.get())

  let maxWordLength = entries.mapIt(it[1].len()).max()
  let maxWordsPerLine = terminalWidth() div (maxWordLength + 2)

  for i in 0 ..< entries.len():
    if not showList:
      stdout.styledWrite(entries[i][0], alignLeft(entries[i][1], maxWordLength + 2))
      if (i + 1) mod maxWordsPerLine == 0:
        echo ""
    else:
      stdout.styledWriteLine(entries[i][0], entries[i][1])

  if not showList: echo ""
