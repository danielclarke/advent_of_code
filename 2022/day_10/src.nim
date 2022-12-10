import std/strscans

type Screen = array[6, array[40, char]]

proc `$`(screen: Screen): string =
  for row in screen:
    for pixel in row:
      if pixel == '#':
        result.add('#')
      else:
        result.add('.')
    result.add('\n')

proc blit(screen: var Screen, cycle, register: int) =
  let row = (cycle - 1) div 40 mod 6
  let col = (cycle - 1) mod 40
  if register - 1 <= col and col <= register + 1:
    screen[row][col] = '#'
  echo screen

proc pixelPos(register: int): string =
  for i in 0 ..< 40:
    if register - 1 <= i and i <= register + 1:
      result.add('#')
    else:
      result.add('.')

# proc partOne() =
#   for line in lines "2022/day_10/data/example.txt":
#     echo ""
#     echo pixelPos(register)
#     echo ""
#     if cycle == 21:
#         return
#     if scanf(line, "noop"):
#       inc cycle
#       if cycle == 20 or (cycle - 20) mod 40 == 0:
#         echo cycle, " ", register, " ", cycle * register
#         strength += cycle * register
#         screen.blit(cycle, register)
#     elif scanf(line, "addx $i", x):
#       inc cycle
#       if cycle == 20 or (cycle - 20) mod 40 == 0:
#         echo cycle, " ", register, " ", cycle * register
#         strength += cycle * register
#         screen.blit(cycle, register)
#       inc cycle
#       register += x
#       if cycle == 20 or (cycle - 20) mod 40 == 0:
#         echo cycle, " ", register, " ", cycle * register
#         strength += cycle * register
#         screen.blit(cycle, register)
#   echo strength
#   echo screen

proc main() =
  var register = 1
  var x = 0

  var cycle = 1

  var screen: Screen

  for line in lines "2022/day_10/data/input.txt":
    echo ""
    echo pixelPos(register)
    echo ""
    if scanf(line, "noop"):
      screen.blit(cycle, register)
      inc cycle
    elif scanf(line, "addx $i", x):
      screen.blit(cycle, register)
      inc cycle
      screen.blit(cycle, register)
      inc cycle
      register += x
  echo screen

when isMainModule:
  main()
