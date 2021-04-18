import os
import strformat
import strutils

var input: seq[char]
var idx: int

proc skip() =
  while len(input) > idx and isSpaceAscii(input[idx]):
    inc(idx)

proc eval(): int =
  skip()

  if isDigit(input[idx]):
    var val = int(input[idx]) - int('0')
    inc(idx)
    while len(input) > idx and isDigit(input[idx]):
      val = val * 10 + (int(input[idx]) - int('0'))
      inc(idx)
    return val

  if input[idx] == '+' or input[idx] == '-':
    var op = input[idx]
    inc(idx)
    var a = eval()
    var b = eval()
    case op
    of '+':
      return a + b
    of '-':
      return a - b
    else:
      quit(fmt"invalid character {op}")
  
  quit(fmt"invalid character {input[idx]}")

proc main() =
  if paramCount() != 1:
    quit("The number of arguments is incorrect.")
  for i in commandLineParams()[0]:
    input.add(i)

  while len(input) > idx:
    echo fmt"{eval()}"
  quit(0)

main()