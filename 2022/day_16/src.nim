import std/[strscans, strutils, pegs, algorithm, sets]

type
  Valve = object
    name: string
    flowRate: int
    index: int
    adj: array[5, int]
    numAdj: int

  Graph = object
    sourceIndex: int
    vertices: seq[Valve]

proc newGraph(): Graph =
  Graph(vertices: newSeq[Valve](0))

proc `$`(g: Graph): string =
  result.add("Source Valve: ")
  result.add($g.sourceIndex)
  result.add(", ")
  result.add(g.vertices[g.sourceIndex].name)
  result.add("\n")
  for i, v in g.vertices.pairs:
    result.add($i)
    result.add(": ")
    result.add($v)
    if i < g.vertices.len:
      result.add("\n")

proc addAdj(v: var Valve; i: int) =
  v.adj[v.numAdj] = i
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

proc addEdge(g: var Graph; fv, tv: string) =
  var fIndex, tIndex: int
  for i, v in g.vertices.pairs:
    if v.name == fv:
      fIndex = i
      continue
    elif v.name == tv:
      tIndex = i
      continue
  g.vertices[fIndex].addAdj(tIndex)

proc index(g: Graph; vname: string): int =
  for v in g.vertices:
    if v.name == vname:
      return v.index

proc parseGraph(fname: string): Graph =
  result = newGraph()

  for line in lines "2022/day_16/data/example.txt":
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
          result.addEdge(fValve, m)
      else:
        raise newException(ValueError, line)

proc main() =
  var graph = parseGraph("2022/day_16/data/example.txt")
  echo graph

when isMainModule:
  main()