type
  Grid = object
    data: seq[seq[int]]

proc width(grid: Grid): int =
  grid.data.len

proc loadFromFile(grid: var Grid, fname: string) =
  let s = fname.readLines(1)[0]
  let gridWidth = s.len
  for line in lines fname:
    grid.data.add(newSeq[int](gridWidth))
    for j, c in line.pairs:
      grid.data[^1][j] = c.int - 48

proc visibleFromLeft(rowIndex, colIndex: int, grid: Grid): bool =
  for u in 0 ..< rowIndex:
    if grid.data[colIndex][u] >= grid.data[colIndex][rowIndex]:
      return false
  true

proc visibleFromRight(rowIndex, colIndex: int, grid: Grid): bool =
  for u in rowIndex + 1 ..< grid.width:
    if grid.data[colIndex][u] >= grid.data[colIndex][rowIndex]:
      return false
  true

proc visibleFromTop(rowIndex, colIndex: int, grid: Grid): bool =
  for u in 0 ..< colIndex:
    if grid.data[u][rowIndex] >= grid.data[colIndex][rowIndex]:
      return false
  true

proc visibleFromBottom(rowIndex, colIndex: int, grid: Grid): bool =
  for u in colIndex + 1 ..< grid.width:
    if grid.data[u][rowIndex] >= grid.data[colIndex][rowIndex]:
      return false
  true

proc visibleFrom(grid: Grid, visibleFromDir: proc(rowIndex, colIndex: int, grid: Grid): bool): seq[seq[char]] =
  result = newSeq[seq[char]](0)
  for i, row in grid.data.pairs:
    result.add(newSeq[char](grid.width))
    for j, tree in row.pairs:
      if visibleFromDir(j, i, grid):
        result[i][j] = (tree + 48).char
      else:
        result[i][j] = '.'

proc visibleCount(grid: Grid): int =
  for i, row in grid.data.pairs:
    for j, tree in row.pairs:
      if visibleFromLeft(j, i, grid):
        inc result
      elif visibleFromRight(j, i, grid):
        inc result
      elif visibleFromTop(j, i, grid):
        inc result
      elif visibleFromBottom(j, i, grid):
        inc result

proc viewLeft(rowIndex, colIndex: int, grid: Grid): int =
  for u in countdown(rowIndex - 1, 0):
    if grid.data[colIndex][u] < grid.data[colIndex][rowIndex]:
      inc result
    else:
      inc result
      return result

proc viewRight(rowIndex, colIndex: int, grid: Grid): int =
  for u in rowIndex + 1 ..< grid.width:
    if grid.data[colIndex][u] < grid.data[colIndex][rowIndex]:
      inc result
    else:
      inc result
      return result

proc viewTop(rowIndex, colIndex: int, grid: Grid): int =
  for u in countdown(colIndex - 1, 0):
    if grid.data[u][rowIndex] < grid.data[colIndex][rowIndex]:
      inc result
    else:
      inc result
      return result

proc viewBottom(rowIndex, colIndex: int, grid: Grid): int =
  for u in colIndex + 1 ..< grid.width:
    if grid.data[u][rowIndex] < grid.data[colIndex][rowIndex]:
      inc result
    else:
      inc result
      return result

proc views(grid: Grid): seq[seq[int]] =
  result = newSeq[seq[int]](0)
  for i, row in grid.data.pairs:
    result.add(newSeq[int](grid.width))
    for j, tree in row.pairs:
      result[i][j] = 1
      result[i][j] *= viewLeft(j, i, grid)
      result[i][j] *= viewRight(j, i, grid)
      result[i][j] *= viewTop(j, i, grid)
      result[i][j] *= viewBottom(j, i, grid)

proc main() =
  var grid = Grid(data: newSeq[seq[int]](0))
  grid.loadFromFile("2022/day_08/data/input.txt")
  echo grid.visibleFrom(visibleFromLeft)
  echo grid.visibleFrom(visibleFromRight)
  echo grid.visibleFrom(visibleFromTop)
  echo grid.visibleFrom(visibleFromBottom)
  echo visibleCount(grid)
  var bestView = 0
  for row in grid.views():
    bestView = max(bestView, max(row))
  echo bestView

when isMainModule:
  main()
