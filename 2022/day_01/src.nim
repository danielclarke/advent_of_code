import std/strscans
import std/algorithm
import std/math

proc getSortedCalories(fname: string): seq[int] =
  var snacks = newSeq[int](1)
  for line in lines fname:
    let (success, calories) = scanTuple(line, "$i")
    if success:
      snacks[snacks.len - 1] += calories
    else:
      snacks.add(0)
  snacks.sort(SortOrder.Descending)
  return snacks

proc sumOfNMostCalories(fname: string, n: int): int =
  let calories = getSortedCalories(fname)
  return calories[0 ..< n].sum()

proc mostCalories(fname: string): int =
  var snacks = newSeq[int](1)
  for line in lines fname:
    let (success, calories) = scanTuple(line, "$i")
    if success:
      snacks[snacks.len - 1] += calories
    else:
      snacks.add(0)
  snacks.sort(SortOrder.Descending)
  return snacks[0]

proc main() =
  echo sumOfNMostCalories("2022/day_01/data/input_01.txt", 3)

when isMainModule:
  main()
