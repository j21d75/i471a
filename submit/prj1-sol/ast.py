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
        jsons = []
        while (not peek('EOF')):
            jsons.append(declaration())
        return jsons

    def declaration():
        r = reserved()        
        s = struct()
        consume('=')
        i = iden()
        consume(';')
       
    def reserved():
        if (peek('const')):
            consume('const')
        elif (peek('let')):
            consume('let')

    def struct():
        if (peek('[')):
            a = array()
        elif (peek('{'):
            o = obj()
        else:
            i = iden()

    def array():
        consume('[')
        s = struct()
        while(peek(',')):
            consume(',')
            s1 = struct()
        consume(']')

    def obj():
        consume('{')
        k = key()
        while(peek(',')):
            consume(',')
            k1 = key()
        consume('}')

    def key():
        i = iden()
        if (peek(':')):
            consume(':')
            s = struct()

    def iden():
        if (peek('ALNU')):

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
    SPACE_RE = re.compile(r'\s+')
    ALNU_RE = re.compile(r'[a-zA-Z_]\w*')
    CHAR_RE = re.compile(r'.')
    def next_match(text):
        m = SPACE_RE.match(text)
        if (m): return (m, None)
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
    if (len(sys.argv) != 2): usage();
    contents = readFile(sys.argv[1]);
    jsons = parse(contents)
    print(json.dumps(jsons, separators=(',', ':'))) #no whitespace

def readFile(path):
    with open(path, 'r') as file:
        content = file.read()
    return content


def usage():
    print(f'usage: {sys.argv[0]} DATA_FILE')
    sys.exit(1)

#use a dict so that we can add attributes dynamically
def json(decl-spec, gId, *gStruct):
    return { 'decl': decl-spec, 'id': gId, 'struct': gStruct }

Token = namedtuple('Token', ['kind', 'lexeme'])

if __name__ == "__main__":
    main()
