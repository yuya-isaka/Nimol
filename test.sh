#!/bin/bash

assert() {
    input="$1"
    expected="$2"

    actual=$(./main "$input")

    if [ "$actual" = "$expected" ]; then
        echo "$input => $actual"
    else
        echo "$input => $expected expected, but got $actual"
        exit 1
    fi
}

nim c main.nim

echo " === basic ==="
assert 0 0
assert 1 1
assert 99 99
assert '1 2 3' '1
2
3'
# assert '1 2 3   ' '1
# 2
# 3'

echo " === arithmetic operators ==="
assert '+ 1 2' 3
assert '+ 5 10' 15
assert '+ 100 200' 300
assert '- 3 2' 1
assert '- 100 200' -100
assert '* 2 3' 6
assert '/ 10 5' 2

assert '+ + + 1 2 3 4' 10
assert '+ 1 + 2 3' 6
assert '* * 3 3 * 3 3' 81
assert '* * 3 3 + 3 1' 36

echo " === functions ==="
assert 'F[+ . .] F(1)' 2
assert 'F[* 2 .] F(3)' 6
assert 'F[/ 100 .] F(2)' 50
assert 'F[* . .] F(F(2))' 16
assert 'F[* . .] F(F(F(2)))' 256
assert 'F[* . .] G[+ F(3) .] G(3)' 12

echo OK

