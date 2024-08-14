import tables

let Icons* = {
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
