import os
import tables
import strformat
import terminal
from icons import Icons

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

  stdout.styledWrite(color, "{icon} {entryParts.name}{entryParts.ext}  ".fmt())


var currentDir = os.getCurrentDir()

for entry in os.walkDir(currentDir):
   processEntry(entry.path)
