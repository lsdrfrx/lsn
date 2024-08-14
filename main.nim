import os
import tables

const Icons = {
  "ext": {
    ".go": "󰟓",
    ".py": "󰌠",
    ".conf": "",
    ".toml": "",
    ".yaml": "e",
    ".jpg": "",
    ".png": "",
    ".html": "",
    ".css": "󰌜",
    ".js": "󰌞",
    ".nim": "",
    ".md": "󰍔",
    ".cpp": "󰙲",
    ".c": "󰙱",
    ".ipynb": "",
    ".json": "",
    ".csv": "",
    ".txt": "",
    ".jsx": "",
    ".tsx": "",
  }.toTable(),

  "name": {
    "Dockerfile": "",
    "node_modules": "",
    "Videos": "",
    "Documents": "",
    "Downloads": "",
    "Music": "",
    "Desktop": "",
  }.toTable(),

  "other": {
    "directory": "",
    "executable": "",
    "plainFile": "",
  }.toTable(),
}.toTable()

proc processEntry(path: string) =
  var entryParts = splitFile(path)
  var icon: string

  if entryParts.ext == "":
    if path.dirExists():
      icon = Icons["other"]["directory"]
    elif path.fileExists():
      icon = " "
    else:
      icon = " "
  elif not Icons["ext"].hasKey(entryParts.ext):
    icon = " "
  else:
    icon = Icons["ext"][entryParts.ext]

  echo icon & " " & entryParts.name & entryParts.ext


var currentDir = os.getCurrentDir()

for entry in os.walkDir(currentDir):
  processEntry(entry.path)
