import vec2

const SIM_LEN = 2022

type
  Chamber = object
    data: array[4 * SIM_LEN, int]
    height: int
    jetPattern: string
    jetIndex: int

  Rock = object
    pattern: array[4, int]
    pos: Vec2
    width: int
    height: int

  Move = enum
    Left,
    Right

proc `[]`(rock: Rock; i: int): int {.inline.} =
  rock.pattern[i]

proc `[]`(chamber: Chamber; i: int): int {.inline.} =
  chamber.data[i]

proc `[]=`(chamber: var Chamber; i, v: int) {.inline.} =
  chamber.data[i] = v

proc newRock(pattern: array[4, int]; pos: Vec2): Rock =
  var height = 0
  for j in countdown(pattern.len - 1, 0):
    if pattern[j] > 0:
      height += 1
  result = Rock(pattern: pattern, pos: pos, height: height)

proc newChamber(jetPattern: string): Chamber =
  Chamber(height: 0, jetPattern: jetPattern)

proc `$`(chamber: Chamber): string =
  for j in countdown(chamber.height, 0):
    if j > chamber.data.len - 1:
      result.add("|.......|")
    else:
      result.add('|')
      for i in 0 .. 6:
        if (chamber[j] and (0b1000000 shr i)) > 0:
          result.add('#')
        else:
          result.add('.')
      result.add("|\n")
  result.add("+-------+")

proc nextMove(chamber: var Chamber): Move =
  if chamber.jetPattern[chamber.jetIndex] == '<':
    result = Left
  if chamber.jetPattern[chamber.jetIndex] == '>':
    result = Right
  chamber.jetIndex += 1
  chamber.jetIndex = chamber.jetIndex mod chamber.jetPattern.len

proc addRock(chamber: var Chamber; rock: Rock) =
  for j, row in rock.pattern.pairs:
    chamber[rock.pos.y + j] = chamber[rock.pos.y + j] or row shr rock.pos.x
  chamber.height = max(chamber.height, rock.pos.y + rock.height)

proc collides(rock: Rock; chamber: Chamber): bool =
  for j, row in rock.pattern.pairs:
    if row > 0 and (rock.pos.y + j < 0):
      return true
    if rock.pos.x < 0:
      return true
    if (row and 0b1111111 shr (7 - rock.pos.x)) > 0:
      return true
    if ((row shr rock.pos.x) and chamber[j + rock.pos.y]) > 0:
      return true
  return false

proc fallRock(chamber: var Chamber; rockPattern: array[4, int]) =
  var rock = newRock(rockPattern, Vec2(x: 2, y: chamber.height + 3))
  let dy = Vec2(x: 0, y: -1)
  while true:

    let nextMove = chamber.nextMove()
    let dx = case(nextMove):
      of Left: Vec2(x: -1, y: 0)
      of Right: Vec2(x: 1, y: 0)
    rock.pos += dx
    if rock.collides(chamber):
      rock.pos -= dx
    rock.pos += dy
    if rock.collides(chamber):
      rock.pos -= dy
      break

  chamber.addRock(rock)

proc main() =
  let rockPatterns = [
    [
    0b1111000,
    0b0000000,
    0b0000000,
    0b0000000,
    ],
    [
    0b0100000,
    0b1110000,
    0b0100000,
    0b0000000,
    ],
    [
    0b1110000,
    0b0010000,
    0b0010000,
    0b0000000,
    ],
    [
    0b1000000,
    0b1000000,
    0b1000000,
    0b1000000,
    ],
    [
    0b1100000,
    0b1100000,
    0b0000000,
    0b0000000,
    ],
  ]

  let jetPattern = "2022/day_17/data/input.txt".readFile

  var chamber = newChamber(jetPattern)

  for i in 0 ..< SIM_LEN:
    chamber.fallRock(rockPatterns[i mod 5])

  # echo chamber
  echo chamber.height

when isMainModule:
  main()
