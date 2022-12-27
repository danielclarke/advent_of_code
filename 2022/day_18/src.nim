import std/[strscans]

type
  Vec3 = object
    x, y, z: int

  LavaModel = object
    data: seq[bool]
    width, height, depth: int

func `+`(u, v: Vec3): Vec3 {.inline.}=
  Vec3(x: u.x + v.x, y: u.y + v.y, z: u.z + v.z)

func `-`(u, v: Vec3): Vec3 {.inline.}=
  Vec3(x: u.x - v.x, y: u.y - v.y, z: u.z - v.z)

proc max(u, v: Vec3): Vec3 {.inline.} =
  Vec3(x: max(u.x, v.x), y: max(u.y, v.y), z: max(u.z, v.z))

proc `[]`(lm: LavaModel; u: Vec3): bool =
  if lm.width <= u.x:
    return false
  if lm.height <= u.y:
    return false
  if lm.depth <= u.z:
    return false
  if u.x < 0:
    return false
  if u.y < 0:
    return false
  if u.z < 0:
    return false
  lm.data[u.x * lm.height * lm.depth + u.y * lm.depth + u.z]

proc `[]=`(lm: var LavaModel; u: Vec3; v: bool) =
  lm.data[u.x * lm.height * lm.depth + u.y * lm.depth + u.z] = v

proc numExposedSurfaces(lm: LavaModel; u: Vec3): int =
  result = 6
  let dx = Vec3(x: 1, y: 0, z: 0)
  let dy = Vec3(x: 0, y: 1, z: 0)
  let dz = Vec3(x: 0, y: 0, z: 1)
  if lm[u + dx]:
    result -= 1
  if lm[u - dx]:
    result -= 1
  if lm[u + dy]:
    result -= 1
  if lm[u - dy]:
    result -= 1
  if lm[u + dz]:
    result -= 1
  if lm[u - dz]:
    result -= 1

proc loadLavaModel(scan: seq[Vec3]): LavaModel =
  var maxV = Vec3(x: 0, y: 0, z: 0)
  for v in scan:
    maxV = max(maxV, v)
  result.data = newSeq[bool]((maxV.x + 1) * (maxV.y + 1) * (maxV.z + 1))
  result.width = maxV.x + 1
  result.height = maxV.y + 1
  result.depth = maxV.z + 1
  for v in scan:
    result[v] = true

proc main() =
  var scan = newSeq[Vec3](0)
  for line in lines "2022/day_18/data/input.txt":
    let (success, x, y, z) = scanTuple(line, "$i,$i,$i")
    if success:
      scan.add(Vec3(x: x, y: y, z: z))
  let lm = loadLavaModel(scan)
  var s = 0
  for v in scan:
    s += lm.numExposedSurfaces(v)
  echo s

when isMainModule:
  main()