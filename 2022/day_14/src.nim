import std/[parseutils, strscans]
import vec2

proc `$`(s: seq[seq[char]]): string =
  for row in s:
    for c in row:
      result.add(c)
      result.add(' ')
    result.add('\n')

proc width(s: seq[seq[char]]): int =
  s[0].len

proc height(s: seq[seq[char]]): int =
  s.len

proc `[]`(s: seq[seq[char]], v: Vec2): char =
  if not v.x in 0 ..< s.width or not v.y in 0 ..< s.height:
    return '.'
  s[v.y][v.x]

proc `[]=`(s: var seq[seq[char]], v: Vec2, c: char) =
  s[v.y][v.x] = c

proc `in`(v: Vec2, s: seq[seq[char]]): bool =
  v.x in 0 ..< s.width and v.y in 0 ..< s.height

iterator segments(s: seq[Vec2]): (Vec2, Vec2) =
  for i in 1 ..< s.len:
    yield (s[i - 1], s[i])

proc parsePath(s: string): seq[Vec2] =
  result = newSeq[Vec2](0)

  var index = 0
  var x = 0
  var y = 0

  while index < s.len:
    index += s.parseInt(x, index)
    index += 1 # ,
    index += s.parseInt(y, index)

    result.add(Vec2(x: x, y: y))

    if scanf(s[index .. ^1], " -> "):
      index += 4

proc loadPaths(fname: string): seq[seq[Vec2]] = 
  result = newSeq[seq[Vec2]](0)
  for line in lines fname:
    result.add(parsePath(line))

proc extremum(paths: seq[seq[Vec2]]): (Vec2, Vec2) =
  var minV = Vec2(x: high(int), y: high(int))
  var maxV = Vec2(x: 0, y: 0)

  for path in paths:
    for v in path:
      minV.x = min(minV.x, v.x)
      minV.y = min(minV.y, v.y)

      maxV.x = max(maxV.x, v.x)
      maxV.y = max(maxV.y, v.y)

  (minV, maxV)

proc newScan(paths: seq[seq[Vec2]]; minV, maxV: Vec2): seq[seq[char]] =
  result = newSeq[seq[char]](maxV.y + 1)
  for j in 0 .. maxV.y:
    result[j] = newSeq[char](maxV.x - minV.x + 1)
    for i in 0 .. maxV.x - minV.x:
      result[j][i] = '.'

  result[0][500 - minV.x] = '+'

  for path in paths:
    for (a, b) in path.segments:
      for j in countup(min(a.y, b.y), max(a.y, b.y)):
        for i in countup(min(a.x, b.x) - minV.x, max(a.x, b.x) - minV.x):
          result[j][i] = '#'

proc newScanWithFloor(paths: seq[seq[Vec2]]; minV, maxV: Vec2): seq[seq[char]] =
  result = newSeq[seq[char]](maxV.y + 1 + 2)
  let width = (result.len) * 3 - 1 + 4
  let offset = (width div 2 - (maxV.x - minV.x) div 2) - 1
  for j in 0 ..< result.len:
    result[j] = newSeq[char](width)
    for i in 0 ..< result[j].len:
      if j == result.len - 1:
        result[j][i] = '#'
      else:
        result[j][i] = '.'

  result[0][500 - minV.x + offset] = '+'

  for path in paths:
    for (a, b) in path.segments:
      for j in countup(min(a.y, b.y), max(a.y, b.y)):
        for i in countup(min(a.x, b.x) - minV.x, max(a.x, b.x) - minV.x):
          result[j][i + offset] = '#'

proc grainFall(scan: var seq[seq[char]], orifice: Vec2): Vec2 =
  result = orifice
  while result in scan:
    if scan[result + Vec2(x: 0, y: 1)] == '.':
      result += Vec2(x: 0, y: 1)
    elif scan[result + Vec2(x: -1, y: 1)] == '.':
      result += Vec2(x: -1, y: 1)
    elif scan[result + Vec2(x: 1, y: 1)] == '.':
      result += Vec2(x: 1, y: 1)
    else:
      return result

proc sandFall(scan: var seq[seq[char]], orifice: Vec2): int =
  while true:
    let restingPlace = grainFall(scan, orifice)
    if not (restingPlace in scan): #(not restingPlace.x in 0 ..< scan.width) or (scan.height <= restingPlace.y):
      break
    else:
      scan[restingPlace.y][restingPlace.x] = 'o'
      result += 1
      if restingPlace.y == 0:
        break

proc partOne() =
  let paths = loadPaths("2022/day_14/data/input.txt")
  let (minV, maxV) = extremum(paths)
  echo minV, " ", maxV
  var scan = newScan(paths, minV, maxV)
  echo scan.sandFall(Vec2(x: 500 - minV.x, y: 0))
  echo scan

proc partTwo() =
  let paths = loadPaths("2022/day_14/data/input.txt")
  let (minV, maxV) = extremum(paths)
  echo minV, " ", maxV
  var scan = newScanWithFloor(paths, minV, maxV)
  let offset = (scan.width div 2 - (maxV.x - minV.x) div 2) - 1
  echo scan.sandFall(Vec2(x: 500 - minV.x + offset, y: 0))
  # echo scan

proc main() =
  partOne()
  partTwo()

when isMainModule:
  main()