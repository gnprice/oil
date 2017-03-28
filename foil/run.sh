#!/bin/bash
#
# Usage:
#   ./run.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

readonly PY=~/src/Python-3.6.1
readonly DIFF=${DIFF:-diff -u}

copy() {
  # The 2to3 grammar supports both Python 2 and Python 3.
  # - it has the old print statement.  Well I guess you still want that!  Gah.
  cp -v $PY/Grammar/Grammar $PY/Lib/lib2to3/Grammar.txt .
  # For comparison
  cp -v $PY/Lib/{token,tokenize}.py .
  mkdir -p pgen2
  cp -v $PY/Lib/lib2to3/pgen2/{__init__,driver,pgen,token,tokenize}.py pgen2
}

compare-grammar() {
  $DIFF Grammar Grammar.txt
}

# pgen2 has BACKQUOTE = 25.  No main.
compare-tokens() {
  $DIFF token.py pgen2/token.py
}

# This is very different -- is it Python 2 vs. Python 3?
compare-tokenize() {
  $DIFF tokenize.py pgen2/tokenize.py
}

# Features from Python 3 used?  Static types?  I guess Python 3.6 has locals with
# foo: str = 1
# 
# Do I want that?
#
# Main things I ran into were:
# - print statement
# - next() is now __next__ 
# - io.StringIO vs. cStringIO.cstringIO()
#
# And occasional exceptions about encoding.  Had to add .encode('utf-8') in a
# few places.
#
# So mostly cosmetic issues.

test-pgen2() {
  pgen2/pgen.py
}

"$@"