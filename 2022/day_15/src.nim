import std/[strscans, algorithm, sets]
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

proc closest(s: Vec2; bs: var seq[Vec2]): Vec2 =
  bs.sort(proc(u, v: Vec2): int = s.mdist(u) - s.mdist(v), SortOrder.Ascending)
  bs[0]

proc signalWidth(sensor: Vec2; row: int; radius: int): int =
  let dist = (sensor.y - row).abs
  max(0, (radius * 2 + 1) - (2 * dist))

proc xLimits(sensor: Vec2; row: int; sWidth: int): (int, int) =
  let x0 = sensor.x - sWidth div 2
  let x1 = sensor.x + sWidth div 2
  (x0, x1)

proc flatten(s: var seq[(int, int)]): seq[(int, int)] =
  result = newSeq[(int, int)](1)
  result[0] = s[0]
  for i in 1 ..< s.len:
    if result[^1][1] in s[i][0] .. s[i][1]:
      result[^1][1] = s[i][1]
    elif result[^1][1] < s[i][0]:
      result.add(s[i])

proc flatten(s: var seq[(int, int)]; minX, maxX: int): seq[(int, int)] =
  result = newSeq[(int, int)](1)
  result[0] = s[0]
  result[0][0] = max(result[0][0], minX)
  result[0][1] = min(result[0][1], maxX)
  for i in 1 ..< s.len:
    if result[^1][1] in s[i][0] .. s[i][1]:
      result[^1][1] = min(s[i][1], maxX)
    elif result[^1][1] < s[i][0]:
      result.add(s[i])
      result[^1][0] = max(result[^1][0], minX)
      result[^1][1] = min(result[^1][1], maxX)

proc partOne() =
  let row = 2000000
  var sensors = newSeq[Vec2](0)
  var beacons = newSeq[Vec2](0)

  for line in lines "2022/day_15/data/input.txt":
    block readLine:
      let (success, sx, sy, bx, by) = scanTuple(line, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i")
      if success:
        sensors.add(Vec2(x: sx, y: sy))
        let beacon = Vec2(x: bx, y: by)
        for b in beacons:
          if b == beacon:
            break readLine
        beacons.add(Vec2(x: bx, y: by))

  var beaconsOnRow = newSeq[Vec2](0)

  for b in beacons:
    if b.y == row:
      beaconsOnRow.add(b)

  var ranges = newSeq[(int, int)](0)

  for s in sensors:
    let b = s.closest(beacons)
    let sWidth = s.signalWidth(row, s.mdist(b))
    if sWidth > 0:
      ranges.add(s.xLimits(row, sWidth))

  ranges.sort(proc(a, b: (int, int)): int = a[0] - b[0], SortOrder.Ascending)

  let flattened = ranges.flatten()

  var numPlaces = 0
  for range in flattened:
    numPlaces += range[1] - range[0] + 1
    for b in beaconsOnRow:
      if b.x in range[0] .. range[1]:
        numPlaces -= 1
        echo b

  echo beacons      
  echo beaconsOnRow
  echo ranges
  echo flattened
  echo numPlaces

proc main() =
  let maxWidth = 4000000
  var sensors = newSeq[Vec2](0)
  var beacons = newSeq[Vec2](0)

  for line in lines "2022/day_15/data/input.txt":
    block readLine:
      let (success, sx, sy, bx, by) = scanTuple(line, "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i")
      if success:
        sensors.add(Vec2(x: sx, y: sy))
        let beacon = Vec2(x: bx, y: by)
        for b in beacons:
          if b == beacon:
            break readLine
        beacons.add(Vec2(x: bx, y: by))

  for row in 0 .. maxWidth:
    if row mod 10000 == 0:
      echo row

    var ranges = newSeq[(int, int)](0)

    for s in sensors:
      let b = s.closest(beacons)
      let sWidth = s.signalWidth(row, s.mdist(b))
      if sWidth > 0:
        ranges.add(s.xLimits(row, sWidth))

    ranges.sort(proc(a, b: (int, int)): int = a[0] - b[0], SortOrder.Ascending)

    let flattened = ranges.flatten(0, maxWidth)
    if flattened.len == 1:
      continue

    echo flattened[0][1] + 1, ", ", row
    echo (flattened[0][1] + 1) * 4000000 + row
    return

when isMainModule:
  main()