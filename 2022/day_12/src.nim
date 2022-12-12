import std/[options, algorithm]

type
  HeightMap = object
    source: (int, int)
    destination: (int, int)
    data: seq[seq[char]]

proc `$`(hm: HeightMap): string =
  for row in hm.data:
    for cell in row:
      result.add(cell)
    result.add('\n')
  result = result[0 ..< ^1]

proc newHeightMap(): HeightMap =
  HeightMap(data: newSeq[seq[char]](0))

proc loadHeightMap(fname: string): HeightMap =
  result = newHeightMap()
  for line in lines fname:
    result.data.add(newSeq[char](0))
    for c in line:
      if c == 'S':
        result.source = (result.data.len - 1, result.data[^1].len)
        echo "Source ", result.source
        result.data[^1].add('a')
      elif c == 'E':
        result.destination = (result.data.len - 1, result.data[^1].len)
        echo "Destination ", result.destination
        result.data[^1].add('z')
      else:
        result.data[^1].add(c)

proc loadHeightMap2(fname: string): HeightMap =
  result = newHeightMap()
  for line in lines fname:
    result.data.add(newSeq[char](0))
    for c in line:
      if c == 'S':
        # result.source = (result.data.len - 1, result.data[^1].len)
        # echo "Source ", result.source
        result.data[^1].add('a')
      elif c == 'E':
        result.source = (result.data.len - 1, result.data[^1].len)
        echo "Destination ", result.source
        result.data[^1].add('z')
      else:
        result.data[^1].add(c)

proc findPath(hm: HeightMap): seq[(int, int)] =
  var dists = newSeq[int](hm.data.len * hm.data[0].len)
  var prev = newSeq[Option[(int, int)]](hm.data.len * hm.data[0].len)

  var queue = newSeq[(int, int)](hm.data.len * hm.data[0].len)
  
  for i, row in hm.data.pairs:
    for j, cell in row:
      dists[i * hm.data[0].len + j] = high(int)
      prev[i * hm.data[0].len + j] = none((int, int))
      queue[i * hm.data[0].len + j] = (i, j)
  dists[hm.source[0] * hm.data[0].len + hm.source[1]] = 0

  while queue.len > 0:
    queue.sort(
      proc(x, y: (int, int)): int = 
        dists[x[0] * hm.data[0].len + x[1]] - dists[y[0] * hm.data[0].len + y[1]], 
        SortOrder.Descending
    )

    let u = queue.pop()

    if dists[u[0] * hm.data[0].len + u[1]] == high(int):
      echo "error arrived at u with no path ", u
      var hmError = newHeightMap()
      for i in 0 ..< hm.data.len:
        hmError.data.add(newSeq[char](0))
        for j in 0 ..< hm.data[0].len:
          if dists[i * hm.data[0].len + j] < high(int):
            hmError.data[^1].add('.')
          elif (i, j) == hm.destination:
            hmError.data[^1].add('E')
          else:
            hmError.data[^1].add(hm.data[i][j])
      echo hmError
      # echo prev
      # echo queue
      return

    if u == hm.destination:
      var v = u
      result = newSeq[(int, int)](0)
      result.add(v)
      while true:
        v = prev[v[0] * hm.data[0].len + v[1]].get()
        result.add(v)
        if v == hm.source:
          result.reverse
          return result

    for x in [-1, 0, 1]:
      for y in [-1, 0, 1]:
        if x == 0 or y == 0:
          let i = x + u[0]
          let j = y + u[1]
          if 0 <= i and i < hm.data.len and 0 <= j and j < hm.data[0].len:
            if hm.data[i][j].ord - hm.data[u[0]][u[1]].ord <= 1:
              var alt = dists[u[0] * hm.data[0].len + u[1]] + 1
              if alt < dists[i * hm.data[0].len + j]:
                dists[i * hm.data[0].len + j] = alt
                prev[i * hm.data[0].len + j] = some(u)

proc findPath2(hm: HeightMap): seq[(int, int)] =
  var dists = newSeq[int](hm.data.len * hm.data[0].len)
  var prev = newSeq[Option[(int, int)]](hm.data.len * hm.data[0].len)

  var queue = newSeq[(int, int)](hm.data.len * hm.data[0].len)
  
  for i, row in hm.data.pairs:
    for j, cell in row:
      dists[i * hm.data[0].len + j] = high(int)
      prev[i * hm.data[0].len + j] = none((int, int))
      queue[i * hm.data[0].len + j] = (i, j)
  dists[hm.source[0] * hm.data[0].len + hm.source[1]] = 0

  while queue.len > 0:
    queue.sort(
      proc(x, y: (int, int)): int = 
        dists[x[0] * hm.data[0].len + x[1]] - dists[y[0] * hm.data[0].len + y[1]], 
        SortOrder.Descending
    )

    let u = queue.pop()

    if dists[u[0] * hm.data[0].len + u[1]] == high(int):
      echo "error arrived at u with no path ", u
      var hmError = newHeightMap()
      for i in 0 ..< hm.data.len:
        hmError.data.add(newSeq[char](0))
        for j in 0 ..< hm.data[0].len:
          if dists[i * hm.data[0].len + j] < high(int):
            hmError.data[^1].add('.')
          elif (i, j) == hm.destination:
            hmError.data[^1].add('E')
          else:
            hmError.data[^1].add(hm.data[i][j])
      echo hmError
      # echo prev
      # echo queue
      return

    if hm.data[u[0]][u[1]] == 'a':
      var v = u
      result = newSeq[(int, int)](0)
      result.add(v)
      while true:
        v = prev[v[0] * hm.data[0].len + v[1]].get()
        result.add(v)
        if v == hm.source:
          result.reverse
          return result

    for x in [-1, 0, 1]:
      for y in [-1, 0, 1]:
        if x == 0 or y == 0:
          let i = x + u[0]
          let j = y + u[1]
          if 0 <= i and i < hm.data.len and 0 <= j and j < hm.data[0].len:
            if hm.data[u[0]][u[1]].ord - hm.data[i][j].ord <= 1:
              var alt = dists[u[0] * hm.data[0].len + u[1]] + 1
              if alt < dists[i * hm.data[0].len + j]:
                dists[i * hm.data[0].len + j] = alt
                prev[i * hm.data[0].len + j] = some(u)

proc partOne() =
  let heightMap = loadHeightMap("2022/day_12/data/input.txt")
  echo heightMap
  let path = heightMap.findPath()
  echo path.len - 1
  echo path


proc partTwo() =
  let heightMap = loadHeightMap2("2022/day_12/data/input.txt")
  echo heightMap
  let path = heightMap.findPath2()
  echo path.len - 1
  echo path

proc main() =
  partOne()
  partTwo()

when isMainModule:
  main()
