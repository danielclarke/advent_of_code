import std/[strscans, pegs, strutils, algorithm]

type Monkey = object
  items: seq[int]
  op: char
  b: string
  divisor: int
  ifTrue: int
  ifFalse: int
  inspectionCount: int

proc newMonkey(): Monkey = 
  result.items = newSeq[int](0)

proc hold(monkey: var Monkey, item: int) =
  monkey.items.add(item)

proc inspect(monkey: var Monkey): int =
  result = monkey.items.pop()
  let v = if monkey.b == "old":
    result
  else:
    monkey.b.parseInt
  if monkey.op == '*':
    result *= v
  elif monkey.op == '+':
    result += v
  inc monkey.inspectionCount

proc throw(monkey: Monkey, item: int): int =
  if item mod monkey.divisor == 0:
    monkey.ifTrue
  else:
    monkey.ifFalse

iterator parseMonkeys(fname: string): Monkey =
  var f = fname.open()

  while true:
    var monkey = newMonkey()
    discard f.readLine() # Monkey 0:
    let itemLine = f.readLine()
    let pItems = peg"""\skip(\s*)Starting items\:( {\d+}\,)*( {\d+})+\s*"""
    if itemLine =~ pItems:
      for m in matches:
        if m == "":
          break
        monkey.hold(m.parseInt)
    
    let opLine = f.readLine()
    let pOp = peg"""\skip(\s*)Operation\: new \= old {[\*, \+]} {\w+}\s*"""
    if opLine =~ pOp:
      monkey.op = matches[0][0]
      monkey.b = matches[1]

    let testLine = f.readLine()
    let pTest = peg"""\skip(\s*)Test\: divisible by {\d+}"""
    if testLine =~ pTest:
      monkey.divisor = matches[0].parseInt

    let trueLine = f.readLine()
    let pTrue = peg"""\skip(\s*)If true\: throw to monkey {\d+}"""
    if trueLine =~ pTrue:
      monkey.ifTrue = matches[0].parseInt

    let falseLine = f.readLine()
    let pFalse = peg"""\skip(\s*)If false\: throw to monkey {\d+}"""
    if falseLine =~ pFalse:
      monkey.ifFalse = matches[0].parseInt
    
    yield monkey

    if f.endOfFile:
      break

    discard f.readLine() # new line

proc partOne() =
  let numRounds = 20
  var monkeys = newSeq[Monkey](0)
  for m in "2022/day_11/data/input.txt".parseMonkeys():
    monkeys.add(m)

  for round in 0 ..< numRounds:
    for monkey in monkeys.mitems:
      while monkey.items.len > 0:
        var item = monkey.inspect()
        item = item div 3
        monkeys[monkey.throw(item)].hold(item)

  sort(monkeys, proc(x, y: Monkey): int = x.inspectionCount - y.inspectionCount, SortOrder.Descending)
  echo monkeys[0].inspectionCount * monkeys[1].inspectionCount

proc partTwo() =
  let numRounds = 10000
  var monkeys = newSeq[Monkey](0)
  for m in "2022/day_11/data/input.txt".parseMonkeys():
    monkeys.add(m)

  var cm = 1
  for monkey in monkeys:
    cm *= monkey.divisor

  for round in 0 ..< numRounds:
    for monkey in monkeys.mitems:
      while monkey.items.len > 0:
        var item = monkey.inspect()
        monkeys[monkey.throw(item)].hold(item mod cm)
  for monkey in monkeys:
    echo monkey

  sort(monkeys, proc(x, y: Monkey): int = x.inspectionCount - y.inspectionCount, SortOrder.Descending)
  echo monkeys[0].inspectionCount * monkeys[1].inspectionCount

proc main() =
  partOne()
  partTwo()

when isMainModule:
  main()
