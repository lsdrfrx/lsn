import std/[os, tables, strformat, sequtils, unicode, options, terminal, parseopt, times]
import icons, entry, colors
from strutils import repeat

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
      of "m":
        showMeta = true
        showList = true
      of "d": showDirsOnly  = true
      of "f": showFilesOnly = true
    of cmdArgument:
      directory = p.key         #

proc isDirectory(path: string): bool =
  return path.dirExists()

proc isFile(path: string): bool =
  return path.fileExists()

proc isExecutable(path: string): bool =
  var permissions = path.getFilePermissions()
  return permissions.contains(fpUserExec) and path.isFile()

proc alignLeftWithANSISequences(e: Entry, length: int): string =
  "{e.meta} {e.color}{e.icon} {e.name}{def}{repeat(' ', length - e.length + 2)}".fmt()

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


proc processEntry(path: string): Option[Entry] =
  let entryParts = splitFile(path)
  var entry = Entry()

  if not showHidden:
    if entryParts.name[0] == '.': return none(Entry)

  if showDirsOnly:
    if path.isFile(): return none(Entry)

  if showFilesOnly:
    if path.isDirectory(): return none(Entry)

  entry.name = "{entryParts.name}{entryParts.ext}".fmt()
  entry.length = entry.name.len() + 2  # + icon and space chars

  if path.isFile():
    entry.icon = Icons["ext"].getOrDefault(entryParts.ext, Icons["other"]["plainFile"])
  elif path.isDirectory():
    entry.icon = Icons["directories"].getOrDefault(entryParts.name, Icons["other"]["directory"])
    entry.color = blue

  if path.isExecutable():
    if entry.icon == Icons["other"]["plainFile"]:
      entry.icon = Icons["other"]["executable"]
    entry.color = green

  if showMeta:
    let info = path.getFileInfo()
    let lastUpdated = path.getLastModificationTime().format("ddd MMM dd hh:mm:ss YYYY")
    let entrySize = align("{path.getFileSize()} B".fmt(), 8)

    let entryPermissions = getPermissionString(info)

    entry.meta = "{entryPermissions} {yellow}{entrySize}{def} {green}{lastUpdated}{def}".fmt()

  return some(entry)

if isMainModule:
  parseCommandLineArgs()

  if directory == "":
    directory = os.getCurrentDir()

  var entries: seq[Entry] = @[]

  for entry in os.walkDir(directory):
    var processed = processEntry(entry.path)
    if processed.isSome:
      entries.add(processed.get())

  if entries.len() != 0:
    let maxWordLength = entries.mapIt(it.name.len()).max()
    let maxWordsPerLine = terminalWidth() div (maxWordLength + 2)

    for i in 0 ..< entries.len():
      if not showList:
        stdout.write(alignLeftWithANSISequences(entries[i], maxWordLength + 2))
        if (i + 1) mod maxWordsPerLine == 0:
          echo ""
      else:
        stdout.writeLine("{entries[i].meta} {entries[i].color}{entries[i].icon} {entries[i].name}{def}".fmt())

    if not showList: echo ""
