import std/[strutils, algorithm]
import fusion/matching

{.experimental: "caseStmtMacros".}

type  
  PacketKind = enum
    pkValue,
    pkPacket

  Packet = object
    case kind: PacketKind
    of pkValue:
      value: int
    of pkPacket:
      packet: seq[Packet]

proc `$`(packet: Packet): string =
  case packet.kind:
  of pkValue:
    result = $packet.value
  of pkPacket:
    result = "["
    for i, p in packet.packet.pairs:
      result.add $p
      if i < packet.packet.len - 1:
        result.add ", "
    result.add "]"

proc add(packet: var Packet, p: Packet) =
  case packet.kind:
  of pkValue:
    discard
  of pkPacket:
    packet.packet.add(p)

proc add(packet: var Packet, i: int) =
  case packet.kind:
  of pkValue:
    discard
  of pkPacket:
    packet.packet.add(Packet(kind: pkValue, value: i))

proc len(packet: Packet): Natural =
  case packet.kind:
  of pkValue:
    discard
  of pkPacket:
    result = packet.packet.len

proc `[]`(packet: Packet, i: Natural): Packet =
  case packet.kind:
  of pkValue:
    discard
  of pkPacket:
    result = packet.packet[i]

proc compare(pkLeft, pkRight: Packet): int =
  case (pkLeft.kind, pkRight.kind):
  of (pkValue, pkValue):
    result = pkLeft.value - pkRight.value
  of (pkPacket, pkValue):
    result = compare(pkLeft, Packet(kind: pkPacket, packet: @[pkRight]))
  of (pkValue, pkPacket):
    result = compare(Packet(kind: pkPacket, packet: @[pkLeft]), pkRight)
  of (pkPacket, pkPacket):
    var i = 0
    while i < pkLeft.len and i < pkRight.len:
      let c = compare(pkLeft[i], pkRight[i])
      if c != 0:
        return c
      i += 1
    if pkLeft.len == pkRight.len:
      result = 0
    elif pkLeft.len < pkRight.len:
      result = -1
    else:
      result = 1

proc scanListAux(line: string, packet: var Packet): int =
  var i = 0
  var buf = ""
  while i < line.len:
    let c = line[i]
    if c == '[':
      var p = Packet(kind: pkPacket, packet: newSeq[Packet](0))
      i += scanListAux(line[i + 1 .. ^1], p) + 1
      packet.add p
    elif c == ']':
      if buf.len > 0:
        packet.add buf.parseInt
      return i + 1
    elif '0' <= c and c <= '9':
      buf.add c
      i += 1
    elif c == ',':
      if buf.len > 0:
        packet.add buf.parseInt
        buf = ""
      i += 1

proc scanList(line: string): Packet =
  result = Packet(kind: pkPacket, packet: newSeq[Packet](0))
  discard scanListAux(line[1 .. ^1], result)

iterator pairs(fname: string): (Packet, Packet) =
  var f = fname.open()

  while true:
    var pkLeft = scanList(f.readLine)
    var pkRight = scanList(f.readLine)
    yield (pkLeft, pkRight)

    if f.endOfFile:
      break
    discard f.readLine

proc main() =
  var sum = 0
  var count = 0

  var packets = newSeq[Packet](0)
  let dividerTwo = Packet(kind: pkPacket, packet: @[Packet(kind: pkPacket, packet: @[Packet(kind: pkValue, value: 2)])])
  let dividerSix = Packet(kind: pkPacket, packet: @[Packet(kind: pkPacket, packet: @[Packet(kind: pkValue, value: 6)])])

  for (pkLeft, pkRight) in pairs "2022/day_13/data/input.txt":
    packets.add(pkLeft)
    packets.add(pkRight)
    count += 1

    let c = compare(pkLeft, pkRight)
    if c <= 0:
      sum += count
  
  # part 1

  echo sum


  # part 2
  
  var multipland = 1  

  packets.add(dividerTwo)
  packets.add(dividerSix)
  packets.sort(compare, SortOrder.Ascending)

  for i, packet in packets.pairs:
    if compare(packet, dividerTwo) == 0 or compare(packet, dividerSix) == 0:
      multipland *= (i + 1)
  echo multipland

when isMainModule:
  main()