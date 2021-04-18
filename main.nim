import os
import strformat
import strutils

var input: seq[char]
var idx: int
var function = newSeq[seq[char]](100) # !使い方をまだよくわかっていない

#-----------------------------------------------------------------------

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
  # buf.add('\n')
  inc(idx)

proc expect(c: char) =
  if input[idx] != c:
    quit(fmt"{c} expected but got {input[idx]}")
  inc(idx)

#----------------------------------------------------------------------

proc eval(args: seq[int]): int

proc evalString(code: seq[char], args: seq[int]): int =
  var orig = input
  var orig2 = idx
  input = code
  idx = 0
  var val: int
  while len(input) > idx: # !関数を実行する時は1番最初の式だけじゃなくて全部を実行したい
    val = eval(args)
    inc(idx)
  input = orig
  idx = orig2
  return val

#------------------------------------------------------------------------------------

# !再帰下降法, 構文解析のテクニック
proc eval(args: seq[int]): int =
  skip()

  # *Function parameter
  if 'a' <= input[idx] and input[idx] <= 'z':
    var tmp = args[int(input[idx]) - int('a')]
    inc(idx)
    return tmp

  # !上にないといけない
  # *Built-int Function
  if input[idx] == 'P':
    inc(idx)
    expect('(')
    var val = eval(args)
    expect(')')
    echo fmt"{val}"
    return val

  # *Funciton definition
  if 'A' <= input[idx] and input[idx] <= 'Z' and input[idx+1] == '[':
    var name: char = input[idx]
    idx += 2
    readUntil(']', function[int(name)-int('A')])
    return eval(args)

  # *Function application
  if 'A' <= input[idx] and input[idx] <= 'Z' and input[idx+1] == '(':
    var newargs = newSeq[int](26)
    var name: char = input[idx]
    idx += 2

    var i = 0
    skip()
    while input[idx] != ')':
      skip()
      newargs[i] = eval(args)
      inc(i)
    expect(')')
    return evalString(function[int(name) - int('A')], newargs)

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
    var a = eval(args)    # !重要！ op 式 式 という形が期待されている
    var b = eval(args)
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

  var tmp = newSeq[int]() #!ダミー
  while len(input) > idx:
    echo fmt"{eval(tmp)}"
  quit(0)

main()