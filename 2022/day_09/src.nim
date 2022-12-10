import std/[sets, strformat, strscans]
import vec2

type
  Direction = enum
    D = 'D'
    L = 'L'
    R = 'R'
    U = 'U'

  Rope = seq[Vec2]

proc newRope(n: Natural): Rope =
  newSeq[Vec2](n)

proc head(rope: var Rope): var Vec2 =
  rope[0]

proc tail(rope: var Rope): var Vec2 =
  rope[^1]

iterator sections(rope: var Rope): (var Vec2, var Vec2) =
  for i in 1 ..< rope.len:
    yield (rope[i - 1], rope[i])

proc move(rope: var Rope, d: char) =
  case d
  of 'R':
    rope.head += Vec2(x: 1, y: 0)
  of 'L':
    rope.head -= Vec2(x: 1, y: 0)
  of 'U':
    rope.head += Vec2(x: 0, y: 1)
  of 'D':
    rope.head -= Vec2(x: 0, y: 1)
  else:
    discard
  for (a, b) in rope.sections:
    let d = a - b
    if d.max >= 2:
      b += d.norm

proc trackTail(fname: string, ropeLen: Natural) =
  var rope = newRope(ropeLen)
  var uniquePositions: HashSet[Vec2] = toHashSet([Vec2(x: 0, y: 0)])
  for line in lines fname:
    let (success, dir, spaces) = scanTuple(line, "$c $i")
    if success:
      for i in 0 ..< spaces:
        rope.move(dir)
        uniquePositions.incl(rope.tail)
  echo uniquePositions.card

proc main() =
  trackTail("2022/day_09/data/input.txt", 2)
  trackTail("2022/day_09/data/input.txt", 10)

when isMainModule:
  main()
