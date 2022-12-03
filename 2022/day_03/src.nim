import std/[sets, sequtils, math]

proc getMisplaced(rucksack: string): char =
  let compartmentA = toHashSet(rucksack[0 ..< rucksack.len div 2])
  let compartmentB = toHashSet(rucksack[rucksack.len div 2 ..< rucksack.len])
  var misplaced = compartmentA.intersection(compartmentB)
  misplaced.pop()

proc priority(item: char): int =
  if 'A' <= item and item <= 'Z':
    item.int - 'A'.int + 27
  else:
    item.int - 'a'.int + 1

proc misplacedPriorities(): int =
  "2022/day_03/data/input.txt".lines.toSeq.map(getMisplaced).map(priority).sum()

proc badge(rucksackA, rucksackB, rucksackC: string): char =
  let rucksackA = rucksackA.toHashSet()
  let rucksackB = rucksackB.toHashSet()
  let rucksackC = rucksackC.toHashSet()
  var badge = rucksackA.intersection(rucksackB).intersection(rucksackC)
  badge.pop()

proc badgePriorities(): int =
  var f = open "2022/day_03/data/input.txt"
  while not f.endOfFile:
    result += badge(f.readLine, f.readLine, f.readLine).priority

proc main() =
  echo misplacedPriorities()
  echo badgePriorities()

when isMainModule:
  main()