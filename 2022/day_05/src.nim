import std/[sequtils, strscans]

proc loadCrates(fname: string): seq[seq[char]] =
  result = newSeq[seq[char]](0)

  for line in fname.lines:
    var crateInt = 0
    if scanf(line, "$s$i$s", crateInt):
      break
    var i = 0
    var crateIndex = 0
    while i < line.len:
      var crate: char
      if scanf(line[i ..< line.len], "[$c]", crate):
        if crateIndex == result.len:
          result.add(newSeq[char](0))
        result[crateIndex].insert(crate, 0)
        i += 3
        crateIndex += 1
      elif scanf(line[i ..< line.len], "$s$s$s"):
        if crateIndex == result.len:
          result.add(newSeq[char](0))
        i += 3
        crateIndex += 1
      if scanf(line[i ..< line.len], "$s"):
        i += 1

proc moveCratesOneAtATime(fname: string, crates: var seq[seq[char]]) =
  for line in fname.lines:
    let (success, moveNum, fromCol, toCol) = scanTuple(line, "move $i from $i to $i")
    if success:
      for i in 0 ..< moveNum:
        crates[toCol - 1].add(crates[fromCol - 1].pop())

proc moveCratesManyAtATime(fname: string, crates: var seq[seq[char]]) =
  for line in fname.lines:
    let (success, moveNum, fromCol, toCol) = scanTuple(line, "move $i from $i to $i")
    if success:
      let fromLen = crates[fromCol - 1].len
      crates[toCol - 1].add(crates[fromCol - 1][fromLen - moveNum ..< fromLen])
      crates[fromCol - 1].setLen(fromLen - moveNum)

proc partOne() =
  let fname = "2022/day_05/data/input.txt"
  var crates = loadCrates(fname)
  moveCratesOneAtATime(fname, crates)
  var topCrates = ""
  for col in crates:
    topCrates.add(col[col.len-1])
  echo topCrates

proc partTwo() =
  let fname = "2022/day_05/data/input.txt"
  var crates = loadCrates(fname)
  moveCratesManyAtATime(fname, crates)
  var topCrates = ""
  for col in crates:
    topCrates.add(col[col.len-1])
  echo topCrates

proc main() =
  partOne()
  partTwo()

when isMainModule:
  main()