import os
import tables
import strformat

const Icons = {
  "ext": {
    ".go": "󰟓",
    ".py": "󰌠",
    ".conf": "",
    ".toml": "",
    ".yaml": "",
    ".jpg": "",
    ".png": "",
    ".html": "",
    ".css": "󰌜",
    ".js": "",
    ".ts": "",
    ".nim": "",
    ".md": "󰍔",
    ".cpp": "󰙲",
    ".c": "󰙱",
    ".ipynb": "",
    ".json": "",
    ".csv": "",
    ".txt": "",
    ".jsx": "",
    ".tsx": "",
  }.toTable(),

  "name": {
    "Dockerfile": "",
  }.toTable(),

  "directories": {
    "node_modules": "",
    "Videos": "",
    "Documents": "",
    "Downloads": "󰇚",
    "Music": "󰝚",
    "Desktop": "",
    "src": "󱃖",
  }.toTable(),

  "other": {
    "directory": "",
    "executable": "",
    "plainFile": "",
  }.toTable(),
}.toTable()

proc isExecutable(path: string): bool =
  var permissions = path.getFilePermissions()
  return permissions.contains(fpUserExec)

proc isDirectory(path: string): bool =
  return path.dirExists()

proc processEntry(path: string): string =
  var entryParts = splitFile(path)
  var icon: string

  if Icons["ext"].hasKey(entryParts.ext):
    icon = Icons["ext"][entryParts.ext]
  elif path.isDirectory():
    icon = Icons["directories"].getOrDefault(entryParts.name, Icons["other"]["directory"])
  else:
    icon = Icons["other"]["plainFile"]

  if path.isExecutable():
    # TODO: Add green color to executable files
    if icon == Icons["other"]["plainFile"]:
      icon = Icons["other"]["executable"]

  return "{icon} {entryParts.name}{entryParts.ext}".fmt()


var currentDir = os.getCurrentDir()

for entry in os.walkDir(currentDir):
   echo processEntry(entry.path)
