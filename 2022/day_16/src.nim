# import nimprof
import std/[strutils, strformat, pegs, heapqueue]

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
    positiveFlowVertices: seq[Valve]
    shortestPaths: seq[int]

  Path = object
    minutesRemaining: int
    currentIndex: int
    releasedPressure: int
    releasePotential: int
    numOpenValves: int
    mOpenValves: array[128, bool]
    numMoves: int
    mMoves: array[32, int]

iterator openValves(p: Path): int =
  for i, v in p.mOpenValves.pairs:
    if v:
      yield i

iterator moves(p: Path): int =
  for i in 0 ..< p.numMoves:
    yield p.mMoves[i]

iterator adjacent(v: Valve): int =
  for i in 0 ..< v.numAdj:
    yield v.adj[i]

proc `<`(a, b: Path): bool =
  (a.releasePotential + a.releasedPressure) >= (b.releasePotential +
      b.releasedPressure)

proc `<`(a, b: (Path, Path)): bool =
  a[0].releasePotential + a[0].releasedPressure +
  a[1].releasePotential + a[1].releasedPressure >=
  b[0].releasePotential + b[0].releasedPressure +
  b[1].releasePotential + b[1].releasedPressure

proc `<`(a, b: seq[int]): bool =
  a.len < b.len

proc index(g: Graph; vname: string): int =
  for v in g.vertices:
    if v.name == vname:
      return v.index

proc name(g: Graph; vIndex: int): string =
  for v in g.vertices:
    if v.index == vIndex:
      return v.name

proc pathLen(g: Graph; fromIndex, toIndex: int): int {.inline.} =
  g.shortestPaths[fromIndex * g.vertices.len + toIndex]

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
      result.add(fmt"{v.name} -> {u.name}: {g.pathLen(i, j)}")
      result.add('\n')

proc valveOpen(p: Path; v: int): bool =
  p.mOpenValves[v]

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

proc findShortestPath(g: Graph; f, t: int): seq[int] =
  var paths = initHeapQueue[seq[int]]()
  paths.push(@[f])
  while paths.len > 0:
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
        paths.push(p)

proc setShortestPaths(graph: var Graph) =
  graph.shortestPaths = newSeq[int](graph.vertices.len * graph.vertices.len)
  for v in graph.vertices:
    if v.index == graph.sourceIndex or v.flowRate > 0:
      for u in graph.vertices:
        if v != u and (u.index == graph.sourceIndex or u.flowRate > 0):
          graph.shortestPaths[v.index * graph.vertices.len +
              u.index] = graph.findShortestPath(v.index, u.index).len - 1

proc setPositiveFlowValves(graph: var Graph) =
  for v in graph.vertices:
    if v.flowRate > 0:
      graph.positiveFlowVertices.add(v)

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
  result.setPositiveFlowValves()

proc openValve(p: var Path; v: int) =
  p.mOpenValves[v] = true
  inc p.numOpenValves
  p.minutesRemaining -= 1

proc addMove(p: var Path; v: int) =
  p.mMoves[p.numMoves] = v
  inc p.numMoves

proc nextPaths(g: Graph; p: Path): seq[Path] =
  result = newSeq[Path](0)
  for v in g.positiveFlowVertices:
    if not p.valveOpen(v.index):
      var path = p
      let sp = g.pathLen(p.currentIndex, v.index)
      path.minutesRemaining -= sp
      if path.minutesRemaining >= 0:
        path.currentIndex = v.index
        path.addMove(v.index)
        path.openValve(v.index)
        path.releasedPressure += path.minutesRemaining * v.flowRate
        result.add(path)

proc nextNonOverlappingPaths(g: Graph; myPath, elePath: Path): seq[(Path, Path)] =
  result = newSeq[(Path, Path)](0)
  for v in g.positiveFlowVertices:
    for u in g.positiveFlowVertices:
      if v != u and
        not myPath.valveOpen(v.index) and
        not elePath.valveOpen(v.index) and
        not myPath.valveOpen(u.index) and
        not elePath.valveOpen(u.index):

        var nextMyPath = myPath
        let mySp = g.pathLen(myPath.currentIndex, v.index)
        if nextMyPath.minutesRemaining - mySp >= 0:
          nextMyPath.minutesRemaining -= mySp
          nextMyPath.currentIndex = v.index
          nextMyPath.addMove(v.index)
          nextMyPath.openValve(v.index)
          nextMyPath.releasedPressure += nextMyPath.minutesRemaining * v.flowRate

        var nextElePath = elePath
        let eleSp = g.pathLen(elePath.currentIndex, u.index)
        if nextElePath.minutesRemaining - eleSp >= 0:
          nextElePath.minutesRemaining -= eleSp
          nextElePath.currentIndex = u.index
          nextElePath.addMove(u.index)
          nextElePath.openValve(u.index)
          nextElePath.releasedPressure += nextElePath.minutesRemaining * u.flowRate

        if nextMyPath != myPath or nextElePath != elePath:
          result.add((nextMyPath, nextElePath))

proc potentialReleases(g: Graph; p: Path): int =
  for v in g.positiveFlowVertices:
    if not p.valveOpen(v.index) and v.flowRate > 0:
      result += max(0, (p.minutesRemaining - g.pathLen(p.currentIndex,
          v.index) - 1) * v.flowRate)

proc potentialReleases(g: Graph; p, q: Path): int =
  for v in g.positiveFlowVertices:
    if not p.valveOpen(v.index) and not q.valveOpen(v.index) and v.flowRate > 0:
      result += max(0, (p.minutesRemaining - g.pathLen(p.currentIndex,
          v.index) - 1) * v.flowRate)

proc isPotentialNextValve(g: Graph; p: Path; v: Valve): bool {.inline.} =
  not p.valveOpen(v.index) and v.flowRate > 0 and p.minutesRemaining >
      g.pathLen(p.currentIndex, v.index)

proc partOne(g: Graph; timeLimit: int): Path =
  var paths = initHeapQueue[Path]()
  var p = Path(minutesRemaining: timeLimit, currentIndex: g.sourceIndex)
  p.releasePotential = g.potentialReleases(p)
  paths.push(p)

  while paths.len > 0:
    let path = paths.pop()

    block pathCheck:
      for i, v in g.vertices:
        # the valve is closed, has a positive flowRate and we have enough time to get there
        if g.isPotentialNextValve(path, v):
          break pathCheck
      return path

    var nextPaths = g.nextPaths(path)
    for np in nextPaths.mitems:
      np.releasePotential = g.potentialReleases(np)
      paths.push(np)

proc partTwo(g: Graph; timeLimit: int): (Path, Path) =
  var paths = initHeapQueue[(Path, Path)]()
  var p = Path(minutesRemaining: timeLimit, currentIndex: g.sourceIndex)
  p.releasePotential = g.potentialReleases(p)
  paths.push((p, p))

  while paths.len > 0:
    let (myPath, elePath) = paths.pop()

    block pathCheck:
      for i, v in g.vertices:
        # the valve is closed, has a positive flowRate and we have enough time to get there
        if (g.isPotentialNextValve(myPath, v) and not elePath.valveOpen(
            v.index)) or (g.isPotentialNextValve(elePath, v) and
            not myPath.valveOpen(v.index)):
          break pathCheck
      return (myPath, elePath)

    var nextPaths = g.nextNonOverlappingPaths(myPath, elePath)
    for (nextMyPath, nextElePath) in nextPaths.mitems:
      nextMyPath.releasePotential = g.potentialReleases(nextMyPath, nextElePath)
      nextElePath.releasePotential = g.potentialReleases(nextElePath, nextMyPath)
      paths.push((nextMyPath, nextElePath))

proc main() =
  var graph = parseGraph("2022/day_16/data/input.txt")
  let p = graph.partOne(30)
  echo p.releasedPressure

  let (myPath, elePath) = graph.partTwo(26)

  echo myPath.releasedPressure, " ", elePath.releasedPressure, " ",
      myPath.releasedPressure + elePath.releasedPressure

when isMainModule:
  main()
