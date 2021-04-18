import os
import strformat
import strutils

var input: seq[char]
var idx: int
var function = newSeq[seq[char]](100) # 使い方をまだよくわかっていない

proc skip() =
  while len(input) > idx and isSpaceAscii(input[idx]):
    inc(idx)

proc strChr(input: string, c: char): bool =
  for i in input:
    if c == i:
      return true
  return false

proc readUntil(c: char, buf: var seq[char]) =
  while input[idx] != c:
    buf.add(input[idx])
    inc(idx)
  buf.add('\n')
  inc(idx)

proc expect(c: char) =
  if input[idx] != c:
    quit(fmt"{c} expected but got {input[idx]}")
  inc(idx)

proc eval(arg: int): int

proc evalString(code: seq[char], arg: int): int =
  var orig = input
  var orig2 = idx
  input = code
  idx = 0
  var val = eval(arg)
  input = orig
  idx = orig2
  return val

# !再帰下降法, 構文解析のテクニック
proc eval(arg: int): int =
  skip()

  # *Function parameter
  if strChr(".", input[idx]):
    inc(idx)
    return arg

  # *Funciton definition
  if 'A' <= input[idx] and input[idx] <= 'Z' and input[idx+1] == '[':
    var name: char = input[idx]
    idx += 2
    readUntil(']', function[int(name)-int('A')])
    return eval(arg)

  # *Function application
  if 'A' <= input[idx] and input[idx] <= 'Z' and input[idx+1] == '(':
    var name: char = input[idx]
    idx += 2
    var newarg = eval(arg)
    expect(')')
    return evalString(function[int(name) - int('A')], newarg)


  # *Literal Numbers
  if isDigit(input[idx]):
    var val = int(input[idx]) - int('0')
    inc(idx)
    while len(input) > idx and isDigit(input[idx]):
      val = val * 10 + (int(input[idx]) - int('0'))
      inc(idx)
    return val

  # *Arithmetic Operators
  if strChr("+-*/", input[idx]):
    var op = input[idx]
    inc(idx)    # !ここで１文字進める
    var a = eval(arg)    # !重要！ op 式 式 という形が期待されている
    var b = eval(arg)
    case op
    of '+':
      return a + b
    of '-':
      return a - b
    of '*':
      return a * b
    of '/':
      return a div b
    else:
      quit(fmt"invalid character {op}")
  
  quit(fmt"invalid character {input[idx]}")

proc main() =
  if paramCount() != 1:
    quit("The number of arguments is incorrect.")
  for i in commandLineParams()[0]:
    input.add(i)

  while len(input) > idx:
    echo fmt"{eval(0)}"
  quit(0)

main()