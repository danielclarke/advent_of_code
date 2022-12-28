import std/[strscans]

type
  Material = enum
    Unknown,
    Air,
    Lava

  Vec3 = object
    x, y, z: int

  LavaModel = object
    data: seq[Material]
    width, height, depth: int

const CUBE_DIRECTIONS = [
  Vec3(x: 1, y: 0, z: 0),
  Vec3(x: 0, y: 1, z: 0),
  Vec3(x: 0, y: 0, z: 1),
  Vec3(x: -1, y: 0, z: 0),
  Vec3(x: 0, y: -1, z: 0),
  Vec3(x: 0, y: 0, z: -1)
]

func `+`(u, v: Vec3): Vec3 {.inline.}=
  Vec3(x: u.x + v.x, y: u.y + v.y, z: u.z + v.z)

func `-`(u, v: Vec3): Vec3 {.inline.}=
  Vec3(x: u.x - v.x, y: u.y - v.y, z: u.z - v.z)

proc max(u, v: Vec3): Vec3 {.inline.} =
  Vec3(x: max(u.x, v.x), y: max(u.y, v.y), z: max(u.z, v.z))

proc inBounds(lm: LavaModel; u: Vec3): bool =
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
  return true

proc `[]`(lm: LavaModel; u: Vec3): Material =
  if not lm.inBounds(u):
    return Air
  lm.data[u.x * lm.height * lm.depth + u.y * lm.depth + u.z]

proc `[]=`(lm: var LavaModel; u: Vec3; v: Material) =
  lm.data[u.x * lm.height * lm.depth + u.y * lm.depth + u.z] = v

proc numExposedSurfaces(lm: LavaModel; u: Vec3): int =
  result = 6
  for cd in CUBE_DIRECTIONS:
    if lm[u + cd] == Lava:
      result -= 1

proc numSurfacesExposedToAir(lm: LavaModel; u: Vec3): int =
  result = 6
  for cd in CUBE_DIRECTIONS:
    if lm[u + cd] != Air:
      result -= 1

proc loadLavaModel(scan: seq[Vec3]): LavaModel =
  const padding = Vec3(x: 1, y: 1, z: 1)
  var maxV = Vec3(x: 0, y: 0, z: 0)
  for v in scan:
    maxV = max(maxV, v + padding)
  result.data = newSeq[Material]((maxV.x + 1) * (maxV.y + 1) * (maxV.z + 1))
  result.width = maxV.x + 1
  result.height = maxV.y + 1
  result.depth = maxV.z + 1
  for v in scan:
    result[v] = Lava

proc floodFill(lm: var LavaModel) =
  var stack = @[Vec3(x: 0, y: 0, z: 0)]
  while stack.len > 0:
    var node = stack.pop()
    lm[node] = Air
    for cd in CUBE_DIRECTIONS:
      if lm.inBounds(node + cd) and lm[node + cd] == Unknown:
        stack.add(node + cd)

proc main() =
  const padding = Vec3(x: 1, y: 1, z: 1)
  var scan = newSeq[Vec3](0)
  for line in lines "2022/day_18/data/input.txt":
    let (success, x, y, z) = scanTuple(line, "$i,$i,$i")
    if success:
      scan.add(Vec3(x: x, y: y, z: z) + padding)
  
  # scan = @[Vec3(x: 1, y: 1, z: 1), Vec3(x: 2, y: 1, z: 1)]
  var lm = loadLavaModel(scan)
  lm.floodFill()
  # echo lm

  var partOne = 0
  for v in scan:
    partOne += lm.numExposedSurfaces(v)
  echo partOne

  var partTwo = 0
  for v in scan:
    partTwo += lm.numSurfacesExposedToAir(v)
  echo partTwo

when isMainModule:
  main()