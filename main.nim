import os
import tables
import strformat
from icons import Icons

proc isExecutable(path: string): bool =
  var permissions = path.getFilePermissions()
  return permissions.contains(fpUserExec)

proc isDirectory(path: string): bool =
  return path.dirExists()

proc isFile(path: string): bool =
  return path.fileExists()

proc processEntry(path: string): string =
  var entryParts = splitFile(path)
  var icon: string

  if path.isFile():
    icon = Icons["ext"].getOrDefault(entryParts.ext, Icons["other"]["plainFile"])
  elif path.isDirectory():
    icon = Icons["directories"].getOrDefault(entryParts.name, Icons["other"]["directory"])
  
  if path.isExecutable():
    # TODO: Add green color to executable files
    icon = Icons["other"]["executable"]

  return "{icon} {entryParts.name}{entryParts.ext}".fmt()


var currentDir = os.getCurrentDir()

for entry in os.walkDir(currentDir):
   echo processEntry(entry.path)
