import os
import tables
import strformat
import terminal
import parseopt
from icons import Icons

var p = initOptParser(commandLineParams())

var directory: string

var showHidden = false          # -a
var showLine = true             # -l
var showMeta = false            # -m
var showDirsOnly = false        # -d

proc isDirectory(path: string): bool =
  return path.dirExists()

proc isFile(path: string): bool =
  return path.fileExists()

proc isExecutable(path: string): bool =
  var permissions = path.getFilePermissions()
  return permissions.contains(fpUserExec) and path.isFile()

proc processEntry(path: string) =
  var entryParts = splitFile(path)
  var icon: string
  var color: ForegroundColor

  if not showHidden:
    if entryParts.name[0] == '.': return

  if showDirsOnly:
    if path.isFile(): return

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

  if showLine:
    stdout.styledWriteLine(color, "{icon} {entryParts.name}{entryParts.ext}".fmt())
  else:
    stdout.styledWrite(color, "{icon} {entryParts.name}{entryParts.ext}\t".fmt())


while true:
  p.next()
  case p.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    case p.key:
    of "a": showHidden = true
    of "l": showLine = false
    of "m": showMeta = true
    of "d": showDirsOnly = true
  of cmdArgument:
    directory = p.key

if directory == "":
  directory = os.getCurrentDir()

for entry in os.walkDir(directory):
  processEntry(entry.path)

if not showLine: echo ""
