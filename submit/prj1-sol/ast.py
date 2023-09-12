#!/usr/bin/env python3

import re
import sys
from collections import namedtuple
import json

"""
program
  : declaration program
  | #empty
  ;
declaration
  : reserved struct '=' iden ';' 
  ;
reserved
  : 'const'
  | 'let'
  ;
struct
  : array
  | obj
  | iden
  ;
array 
  : '[' struct ( ',' struct )* ']'
  ;
obj
  : '{' key ( ',' key )* '}'
  ;
key
  : iden
  | iden ':' struct
  ;
iden
  : ALNU
  ;
"""

def parse(text):

    def peek(kind): return lookahead.kind == kind
    def consume(kind):
        nonlocal lookahead
        if (lookahead.kind == kind):
            lookahead = nextToken()
        else:
            print(f'expecting {kind} at {lookahead.lexeme}',
                  file=sys.stderr)
            sys.exit(1)
    def nextToken():
        nonlocal index
        if (index >= len(tokens)):
            return Token('EOF', '<EOF>')
        else:
            tok = tokens[index]
            index += 1
            return tok

    def program():
        asts = []
        while (not peek('EOF')):
            asts.append(declaration())
        return asts

    def declaration():
        r = reserved()
        s = struct()
        consume('=')
        i = iden()
        consume(';')
        return ast(r, i, s)
       
    def reserved():
        if (peek('const') or (peek('let'))):
            kind = lookahead.kind
            consume(kind)
            return kind
        else:
            print(f'missing declaration', file=sys.stderr)
            sys.exit(1)

    def struct():
        if (peek('[')):
            a = array()
            return a
        elif (peek('{')):
            o = obj()
            return o
        else:
            i = iden()
            return i

    def array():
        arr = []
        consume('[')
        if (peek(']')):
            print(f'empty array', file=sys.stderr)
            sys.exit(1)
        s = (struct())
        arr.append(s)
        while(peek(',')):
            consume(',')
            if (peek(']')):
                print(f'extra comma', file=sys.stderr)
                sys.exit(1)
            s1 = (struct())
            arr.append(s1)
        if (peek('ALNU')):
            print(f'missing comma', file=sys.stderr)
            sys.exit(1)
        consume(']')
        return arr

    def obj():
        Dict = {}
        ind = 0
        consume('{')
        if (peek('}')):
            print(f'empty object-struct', file=sys.stderr)
            sys.exit(1)
        k1, k2 = key()
        Dict[k1] = k2
        while(peek(',')):
            consume(',')
            if (peek('}')):
                print(f'extra comma', file=sys.stderr)
                sys.exit(1)
            k3, k4 = key()
            Dict[k3] = k4
        consume('}')
        return Dict

    def key():
        i = iden()
        if (peek(':')):
            consume(':')
            s = struct()
            return i, s
        elif (peek('ALNU')):
            print(f'missing colon', file=sys.stderr)
            sys.exit(1)
        else:
            return i, i

    def iden():
        if (peek('ALNU')):
            value = lookahead.lexeme
            consume('ALNU')
            return value
        elif (peek('const') | peek('let')):
            print(f'reserved id', file=sys.stderr)
            sys.exit(1)

    #begin parse()
    tokens = scan(text)
    index = 0
    lookahead = nextToken()
    value = program()
    if (not peek('EOF')):
        print(f'expecting <EOF>, got {lookahead.lexeme}', file=sys.stderr)
        sys.exit(1)
    return value

def scan(text):
    SPACE_RE = re.compile(r'\s+|//.*')
    CONST_RE = re.compile(r'const')
    LET_RE = re.compile(r'let')
    ALNU_RE = re.compile(r'[a-zA-Z_]\w*')
    CHAR_RE = re.compile(r'.')
    def next_match(text):
        m = SPACE_RE.match(text)
        if (m): return (m, None)
        m = CONST_RE.match(text)
        if (m): return (m, 'const')
        m = LET_RE.match(text)
        if (m): return (m, 'let')
        m = ALNU_RE.match(text)
        if (m): return (m, 'ALNU')
        m = CHAR_RE.match(text)  #must be last: match any char
        if (m): return (m, m.group())

    tokens = []
    while (len(text) > 0):
        (match, kind) = next_match(text)
        lexeme = match.group()
        if (kind): tokens.append(Token(kind, lexeme))
        text = text[len(lexeme):]
    return tokens

def main():
    contents = sys.stdin.read();
    asts = parse(contents)
    print(json.dumps(asts, separators=(',', ':'))) #no whitespace

#use a dict so that we can add attributes dynamically
def ast(declSpec, gId, gStruct):
    return { 'decl': declSpec, 'id': gId, 'struct': gStruct }

Token = namedtuple('Token', ['kind', 'lexeme'])

if __name__ == "__main__":
    main()
