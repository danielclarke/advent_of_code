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

let codeShapeMap = newTable([
  ('A', Rock),
  ('B', Paper),
  ('C', Scissors)
])

let codeGameResultMap = newTable([
  ('X', Loss),
  ('Y', Draw),
  ('Z', Win)
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

func shapeResponse(opponent: Shapes, gameResult: GameResult): Shapes =
  case (opponent, gameResult):
    of (Rock, Loss):
      return Scissors
    of (Rock, Draw):
      return Rock
    of (Rock, Win):
      return Paper
    of (Paper, Loss):
      return Rock
    of (Paper, Draw):
      return Paper
    of (Paper, Win):
      return Scissors
    of (Scissors, Loss):
      return Paper
    of (Scissors, Draw):
      return Scissors
    of (Scissors, Win):
      return Rock

proc tournamentPoints(fname: string): int =
  for line in lines(fname):
    let (success, opponent, gameResult) = scanTuple(line, "$c $c")
    if success:
      let opponent = codeShapeMap[opponent]
      let gameResult = codeGameResultMap[gameResult]
      let response = shapeResponse(opponent, gameResult)
      result += shapePointMap[response]
      result += gameResultPointMap[gameResult]

proc main() =
  echo tournamentPoints("2022/day_02/data/input.txt")

when isMainModule:
  main()
