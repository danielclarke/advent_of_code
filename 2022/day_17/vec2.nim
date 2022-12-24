type
  Vec2* = object
    x*, y*: int

func `+`*(u, v: Vec2): Vec2 =
  Vec2(x: u.x + v.x, y: u.y + v.y)

func `-`*(u, v: Vec2): Vec2 =
  Vec2(x: u.x - v.x, y: u.y - v.y)

func `-`*(v: Vec2): Vec2 =
  Vec2(x: -v.x, y: -v.y)

func `*`*(u, v: Vec2): Vec2 =
  Vec2(x: u.x * v.x, y: u.y * v.y)

func `*`*(v: Vec2, s: int): Vec2 =
  Vec2(x: v.x * s, y: v.y * s)

func `+=`*(u: var Vec2; v: Vec2) =
  u = u + v

func `-=`*(u: var Vec2; v: Vec2) =
  u = u - v

func `*=`*(v: var Vec2, s: int) =
  v = v * s

func `*`*(s: int, v: Vec2): Vec2 =
  v * s

func mag*(v: Vec2): int =
  v.x.abs + v.y.abs

func max*(v: Vec2): int =
  max(v.x.abs, v.y.abs)

func norm*(v: Vec2): Vec2 =
  let x = if v.x == 0:
    0
  else:
    v.x div v.x.abs
  let y = if v.y == 0:
    0
  else:
    v.y div v.y.abs
  Vec2(x: x, y: y)

func abs*(v: Vec2): Vec2 =
  Vec2(x: v.x.abs, y: v.y.abs)

func mdist*(u, v: Vec2): int =
  (u - v).mag