import std/[algorithm, strformat, strscans, tables]

type
  FileSystemKind = enum
    Directory,
    File

  FileSystem = ref object
    parent: FileSystem
    name: string
    case kind: FileSystemKind
    of Directory:
      contents: TableRef[string, FileSystem]
    of File:
      size: int

proc `$`(fs: FileSystem): string =
  fs.name

proc dsize(fs: FileSystem): int =
  case fs.kind:
  of Directory:
    for child in fs.contents.values:
      result += child.dsize
  of File:
    result = fs.size

proc newFileSystem(): FileSystem =
  result = FileSystem(kind: Directory, name: "/", contents: newTable[string, FileSystem]())
  result.parent = result

proc newFile(name: string, size: int, parent: FileSystem): FileSystem =
  result = FileSystem(kind: File, parent: parent, name: name, size: size)

proc newDirectory(name: string, parent: FileSystem): FileSystem =
  result = FileSystem(kind: Directory, parent: parent, name: name, contents: newTable[string, FileSystem]())

proc add(fs, f: var FileSystem) =
  case fs.kind:
  of Directory:
    fs.contents[f.name] = f
  of File:
    echo "Can't add to File"

proc loadFileSystem(cmdFile: string): FileSystem =
  var fs = newFileSystem()
  var currentDir = fs
  var fname: string
  var fext: string
  var fileSize: int
  for line in lines cmdFile:
    if scanf(line, "$$ cd /"):
      currentDir = fs
    elif scanf(line, "$$ cd .."):
      echo "cd from ", currentDir, " to ", currentDir.parent
      currentDir = currentDir.parent
    elif scanf(line, "$$ cd $w", fname):
      echo "cd from ", currentDir, " to ", fname
      echo currentDir.contents
      currentDir = currentDir.contents[fname]
    elif scanf(line, "$$ ls"):
      discard
    elif scanf(line, "dir $w", fname):
      echo "adding dir ", fname
      var dir = newDirectory(fname, currentDir)
      currentDir.add(dir)
      echo currentDir.contents
    elif scanf(line, "$i $w.$w", fileSize, fname, fext):
      echo "adding file ", fname, ".", fext
      var f = newFile(fmt("{fname}.{fext}"), fileSize, currentDir)
      currentDir.add(f)
      echo currentDir.contents
    elif scanf(line, "$i $w", fileSize, fname):
      echo "adding file ", fname
      var f = newFile(fmt("{fname}"), fileSize, currentDir)
      currentDir.add(f)
      echo currentDir.contents
  fs

proc filterAux(fs: FileSystem, f: proc(fs: FileSystem): bool, fss: var seq[FileSystem]) =
  case fs.kind:
  of Directory:
    if f(fs):
      fss.add(fs)
    for child in fs.contents.values:
      filterAux(child, f, fss)
  of File:
    discard

proc filter(fs: FileSystem, f: proc(fs: FileSystem): bool): seq[FileSystem] =
  result = newSeq[FileSystem](0)
  filterAux(fs, f, result)

proc dirsLargerThan(fs: FileSystem, size: int): seq[FileSystem] =
  result = fs.filter(proc(fs: FileSystem): bool = fs.dsize > size)
  result.sort(proc(x, y: FileSystem): int = x.dsize - y.dsize, SortOrder.Ascending)


proc smallDirsAux(fs: FileSystem, maxSize: int, fss: var seq[FileSystem]) =
  for child in fs.contents.values:
    case child.kind:
    of Directory:
      if child.dsize <= maxSize:
        fss.add(child)
      child.smallDirsAux(maxSize, fss)
    of File:
      discard

proc smallDirs(fs: FileSystem, maxSize: int): seq[FileSystem] =
  result = newSeq[FileSystem](0)
  smallDirsAux(fs, maxSize, result)

proc partOne(fs: FileSystem) =
  let smallDirs = fs.smallDirs(100000)
  var sum = 0
  for d in smallDirs:
    sum += d.dsize
  echo sum

proc partTwo(fs: FileSystem) =
  let diskSpace = 70000000
  let updateSpace = 30000000
  let freeSpace = diskSpace - fs.dsize
  let requiredSpace = updateSpace - freeSpace
  let largeDirs = fs.dirsLargerThan(requiredSpace)
  echo largeDirs[0].dsize

proc main() =
  let fs = loadFileSystem "2022/day_07/data/input.txt"
  partOne(fs)
  partTwo(fs)


when isMainModule:
  main()
