# import nimprof
import std/[strscans, strutils, strformat, pegs, algorithm, sets, heapqueue]

type
  Valve = object
    name: string
    flowRate: int
    index: int
    adj: array[5, int]
    dists: array[5, int]
    numAdj: int

  Graph = object
    sourceIndex: int
    vertices: seq[Valve]
    shortestPaths: seq[int]

  Path = object
    minutesRemaining: int
    currentIndex: int
    releasedPressure: int
    releasePotential: int
    numOpenValves: int
    mOpenValves: array[15, int]
    numMoves: int
    mMoves: array[32, int]

iterator openValves(p: Path): int =
  for i in 0 ..< p.numOpenValves:
    yield p.mOpenValves[i]

iterator moves(p: Path): int =
  for i in 0 ..< p.numMoves:
    yield p.mMoves[i]

iterator adjacent(v: Valve): int =
  for i in 0 ..< v.numAdj:
    yield v.adj[i]

proc `<`(a, b: Path): bool = 
  (a.releasePotential + a.releasedPressure) >= (b.releasePotential + b.releasedPressure)

proc index(g: Graph; vname: string): int =
  for v in g.vertices:
    if v.name == vname:
      return v.index

proc name(g: Graph; vIndex: int): string =
  for v in g.vertices:
    if v.index == vIndex:
      return v.name

proc newGraph(): Graph =
  Graph(vertices: newSeq[Valve](0))

proc toString(g: Graph; v: Valve): string =
  result.add(fmt"name: {v.name}, ")
  result.add(fmt"index: {v.index}, ")
  result.add(fmt"flowRate: {v.flowRate}, ")
  result.add(" [")

  for i in v.adjacent:
    result.add(fmt"{g.name(i)}, ")
  result.add("]")

proc `$`(g: Graph): string =
  result.add("Source Valve: ")
  result.add($g.sourceIndex)
  result.add(", ")
  result.add(g.vertices[g.sourceIndex].name)
  result.add("\n")
  for i, v in g.vertices.pairs:
    result.add($i)
    result.add(": ")
    result.add(g.toString(v))
    if i < g.vertices.len:
      result.add("\n")

  for i, v in g.vertices.pairs:
    for j, u in g.vertices.pairs:
      result.add(fmt"{v.name} -> {u.name}: {g.shortestPaths[i * g.vertices.len + j]}")
      result.add('\n')

proc shortestPath(g: Graph; f, t: int): seq[int] =
  var paths = newSeq[seq[int]](1)
  paths[0] = newSeq[int](1)
  paths[0][0] = f
  while paths.len > 0:
    paths.sort(proc(a, b: seq[int]): int = a.len - b.len, SortOrder.Descending)
    let path = paths.pop()
    for v in g.vertices[path[^1]].adjacent:
      block vertices:
        var p = path

        for u in p: # ignore cycles
          if v == u:
            break vertices

        p.add(v)
        if v == t:
          return p
        paths.add(p)

proc setShortestPaths(graph: var Graph) =
  graph.shortestPaths = newSeq[int](graph.vertices.len * graph.vertices.len)
  for v in graph.vertices:
    if v.index == graph.sourceIndex or v.flowRate > 0:
      for u in graph.vertices:
        if v != u and (u.index == graph.sourceIndex or u.flowRate > 0):
          graph.shortestPaths[v.index * graph.vertices.len + u.index] = graph.shortestPath(v.index, u.index).len - 1

proc addAdj(v: var Valve; i: int; dist: int) =
  v.adj[v.numAdj] = i
  v.dists[v.numAdj] = dist
  inc v.numAdj

proc addValve(g: var Graph; name: string) =
  for v in g.vertices:
    if v.name == name:
      return
  if name == "AA":
    g.sourceIndex = g.vertices.len
  g.vertices.add(Valve(name: name, index: g.vertices.len, adj: [-1, -1, -1, -1, -1]))

proc setFlowRate(g: var Graph; name: string; flowRate: int) =
  for v in g.vertices.mitems:
    if v.name == name:
      v.flowRate = flowRate
      return 

proc addEdge(g: var Graph; fv, tv: string; dist: int) =
  let fIndex = g.index(fv)
  let tIndex = g.index(tv)
  g.vertices[fIndex].addAdj(tIndex, dist)

proc parseGraph(fname: string): Graph =
  result = newGraph()
  for line in lines fname:
    block pegMatch:
      let p = peg"""\skip(\s*)Valve {\a\a} has flow rate\={\d+}\; tunnel(s)* lead(s)* to valve(s)* ({\a\a}\, )*{\a\a}*\s*"""
      if line =~ p:
        let fValve = matches[0]
        let flowRate = matches[1]

        result.addValve(fValve)
        result.setFlowRate(fValve, flowRate.parseInt)

        for m in matches[2 .. ^1]:
          if m == "":
            break pegMatch
          result.addValve(m)
          result.addEdge(fValve, m, 1)
      else:
        raise newException(ValueError, line)
  result.setShortestPaths()

proc valveOpen(p: Path; v: int): bool =
  for ov in p.openValves:
    if v == ov:
      return true
  return false

proc openValve(p: var Path; v: int) =
  p.mOpenValves[p.numOpenValves] = v
  inc p.numOpenValves
  p.minutesRemaining -= 1

proc addMove(p: var Path; v: int) =
  p.mMoves[p.numMoves] = v
  inc p.numMoves

proc releasePerMinute(g: Graph; p: Path): int =
  for i in 0 .. p.numOpenValves:
    result += g.vertices[i].flowRate

proc allValvesOpen(g: Graph; p: Path): bool =
  for v in g.vertices:
    if not p.valveOpen(v.index) and v.flowRate > 0:
      return false
  return true

# proc shortestPath(g: Graph; f, t: int): seq[int] =
#   var paths = newSeq[seq[int]](1)
#   var foundPaths = newSeq[seq[int]](0)
#   paths[0] = newSeq[int](1)
#   paths[0][0] = f
#   while paths.len > 0:
#     let path = paths.pop()
#     for v in g.vertices[path[^1]].adjacent:
#       block vertices:
#         var p = path

#         for u in p: # ignore cycles
#           if v == u:
#             break vertices

#         p.add(v)
#         if v == t:
#           foundPaths.add(p)
#         paths.add(p)
#   foundPaths.sort(proc(a, b: seq[int]): int = a.len - b.len, SortOrder.Ascending)
#   foundPaths[0]

proc releasesRemaining(g: Graph; p: Path): seq[Path] =
  result = newSeq[Path](0)
  for v in g.vertices:
    if not p.valveOpen(v.index) and v.flowRate > 0:
      var path = p
      let sp = g.shortestPaths[p.currentIndex * g.vertices.len + v.index]
      path.currentIndex = v.index
      path.minutesRemaining -= sp
      if path.minutesRemaining >= 0:
        path.addMove(v.index)
        path.openValve(v.index)
        path.releasedPressure += path.minutesRemaining * v.flowRate
        result.add(path)
  result.sort(proc(a, b: Path): int = a.releasedPressure - b.releasedPressure, SortOrder.Ascending)

proc potentialReleases(g: Graph; p: Path): int =
  result = 0
  for v in g.vertices:
    if not p.valveOpen(v.index) and v.flowRate > 0:
      result += max(0, (p.minutesRemaining - g.shortestPaths[p.currentIndex * g.vertices.len + v.index]) * v.flowRate)

proc toString(g: Graph; p: Path): string =
  result.add(fmt"minutesRemaining: {p.minutesRemaining}")
  result.add("\n")
  result.add(fmt"currentIndex: {p.currentIndex}")
  result.add("\n")
  result.add(fmt"releasedPressure: {p.releasedPressure}")
  result.add("\n")
  result.add(fmt"releasePotential: {p.releasePotential}")
  result.add("\n")
  result.add(fmt"numOpenValves: {p.numOpenValves}")
  result.add("\n")
  result.add(fmt"openValves: [")
  for i in p.openValves:
    result.add(fmt"{g.name(i)}, ")
  result[^2] = ']'
  result[^1] = ' '
  result.add("\n")

  result.add(fmt"closedValves: [")
  for v in g.vertices:
    if not p.valveOpen(v.index) and v.flowRate > 0:
      result.add(fmt"{v.name}, ")
  result[^2] = ']'
  result[^1] = ' '
  result.add("\n")

  result.add(fmt"moves: [")
  for i in p.moves:
    result.add(fmt"{g.name(i)}, ")
  result[^2] = ']'
  result[^1] = ' '

proc releaseValves(g: var Graph): int =
  var finishedPaths = newSeq[Path](0)
  var newPaths = newSeq[Path](1)
  var paths = newSeq[Path](0)
  newPaths[0] = Path(minutesRemaining: 30, currentIndex: g.sourceIndex)

  while newPaths.len > 0:
    echo finishedPaths.len
    paths = newPaths
    newPaths.setLen(0)
    for path in paths:
      let nextPaths = g.releasesRemaining(path)
      for np in nextPaths:
        if g.allValvesOpen(np) or np.minutesRemaining <= 0:
          finishedPaths.add(np)
        else:
          newPaths.add(np)
  
  finishedPaths.sort(proc(a, b: Path): int = a.releasedPressure - b.releasedPressure, SortOrder.Ascending)

  # for fp in finishedPaths:
  #   echo g.toString(fp)

  echo g.toString(finishedPaths[^1])

proc releaseValves2(g: Graph): int =
  var paths = initHeapQueue[Path]()
  var p = Path(minutesRemaining: 30, currentIndex: g.sourceIndex)
  p.releasePotential = g.potentialReleases(p)
  paths.push(p)

  # var count = 0

  while paths.len > 0:
    let path = paths.pop()

    # if count mod 100 == 0:
    #   echo path.releasePotential
    # count += 1

    block pathCheck:
      for i, v in g.vertices:
        if not path.valveOpen(v.index) and v.flowRate > 0 and path.minutesRemaining > g.shortestPaths[path.currentIndex * g.vertices.len + v.index]:
          break pathCheck
      echo g.toString(path)
      return

    var nextPaths = g.releasesRemaining(path)
    for np in nextPaths.mitems:
      np.releasePotential = g.potentialReleases(np)
      paths.push(np)

proc main() =
  var graph = parseGraph("2022/day_16/data/input.txt")
  echo graph
  echo graph.releaseValves2()

  # let sp = graph.shortestPath(0, 8)
  # var s = ""
  # for i in sp:
  #   s.add(graph.name(i))
  #   s.add(", ")
  # echo s

when isMainModule:
  main()