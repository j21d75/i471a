#!/bin/sh

#sets dir to directory containing this script
dir=`dirname $0`
$dir/ast.py
#use $dir/ as prefix to run any programs in this dir
#so that this script can be run from any directory.


