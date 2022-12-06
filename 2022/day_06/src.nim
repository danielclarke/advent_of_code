type
  CircularBuffer[T] = object
    size: Natural
    index: Natural
    buffer: seq[T]

proc newCircularBuffer[T](size: Natural): CircularBuffer[T] =
  CircularBuffer[T](size: size, index: 0, buffer: newSeq[T](size))

proc insert[T](cb: var CircularBuffer[T], v: T) =
  cb.buffer[cb.index] = v
  cb.index = (cb.index + 1) mod cb.size

proc markerStart(s: string, markerLength: int): int =
  var cb = newCircularBuffer[char](markerLength)
  for i, c in s.pairs:
    cb.insert(c)
    if i >= markerLength - 1:
      var s: set[range['a' .. 'z']]
      for c in cb.buffer:
        s.incl c
      if s.len == markerLength:
        return i + 1

proc main() =
  const packetLength = 4
  const messageLength = 14
  for line in lines "2022/day_06/data/input.txt":
    echo markerStart(line, packetLength), " ", markerStart(line, messageLength)


when isMainModule:
  main()
