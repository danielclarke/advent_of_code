import std/[strscans, tables]
import fusion/matching

{.experimental: "caseStmtMacros".}

type
  Shapes = enum
    Rock,
    Paper,
    Scissors

  GameResult = enum
    Loss,
    Draw,
    Win

let codeMap = newTable([
    ('A', Rock),
    ('B', Paper),
    ('C', Scissors),
    ('X', Rock),
    ('Y', Paper),
    ('Z', Scissors)
  ])

let shapePointMap = newTable([
  (Rock, 1),
  (Paper, 2),
  (Scissors, 3)
])

let gameResultPointMap = newTable([
  (Loss, 0),
  (Draw, 3),
  (Win, 6),
])

func gameResult(opponent, response: Shapes): GameResult =
  case (opponent, response):
    of (Rock, Scissors):
      return Loss
    of (Rock, Rock):
      return Draw
    of (Rock, Paper):
      return Win
    of (Paper, Rock):
      return Loss
    of (Paper, Paper):
      return Draw
    of (Paper, Scissors):
      return Win
    of (Scissors, Paper):
      return Loss
    of (Scissors, Scissors):
      return Draw
    of (Scissors, Rock):
      return Win

proc tournamentPoints(fname: string): int =
  for line in lines(fname):
    let (success, opponent, response) = scanTuple(line, "$c $c")
    if success:
      let opponent = codeMap[opponent]
      let response = codeMap[response]
      result += shapePointMap[response]
      result += gameResultPointMap[gameResult(opponent, response)]

proc main() =
  echo tournamentPoints("2022/day_02/data/input.txt")

when isMainModule:
  main()
