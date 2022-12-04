import std/[sequtils, strscans]

type
  SectionRange = tuple
    first, last: int

func ident[T](v: T): T = v

func overlap[T](a, b: set[T]): bool {.inline.}=
  let common = a * b
  common.len > 0

func contained[T](a, b: set[T]): bool {.inline.}=
  let common = a * b
  a <= common or b <= common

func rangeContained(sr: (SectionRange, SectionRange)): bool =
  let (a, b) = sr
  let left = {a.first .. a.last}
  let right = {b.first .. b.last}
  contained(left, right)

func rangeOverlap(sr: (SectionRange, SectionRange)): bool =
  let (a, b) = sr
  let left = {a.first .. a.last}
  let right = {b.first .. b.last}
  overlap(left, right)

iterator sectionRanges(fname: string): (SectionRange, SectionRange) =
  for line in fname.lines:
    let (success, a, b, u, v) = scanTuple(line, "$i-$i,$i-$i")
    if success:
      yield ((a, b), (u, v))

proc main() =
  echo "2022/day_04/data/input.txt".sectionRanges.toSeq.map(rangeContained).filter(ident).len
  echo "2022/day_04/data/input.txt".sectionRanges.toSeq.map(rangeOverlap).filter(ident).len

when isMainModule:
  main()