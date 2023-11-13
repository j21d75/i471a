module Main (main) where

import TestUtils
import EvalIntExpr (testEvalIntExpr)
import EvalIdExpr (testEvalIdExpr)
import EvalMaybeExpr (testEvalMaybeExpr)
import PostfixExpr (testPostfixExpr)

import Test.QuickCheck

---------------------------- toSingletonLists ---------------------------
-- #1: 5-points
-- Use the map function to transform a list of elements e into
-- a list of singleton lists [e].
-- Hint: use map with a section.
toSingletonLists :: [a] -> [[a]]

toSingletonLists list = map (\x -> [x]) list

testToSingletonLists = do
  print "******* toSingletonLists"
  quickCheck $ counterexample "ints" $
    toSingletonLists [ 5, 7, 2 ] == [ [5], [7], [2] ]
  quickCheck $ counterexample "chars" $
    toSingletonLists [ 'a', 'x', 'd' ] == [ "a", "x", "d" ]
  quickCheck $ counterexample "empty" $
    toSingletonLists [] == ([] :: [[Int]])

--------------------------------- listMap -------------------------------
-- #2: 5-points
-- Return a list containing f a e for each element in list.
-- Hint: use the map function or a list comprehension
listMap :: (a -> b -> c) -> a -> [b] -> [c]

listMap f a list = map (\x -> f a x) list 

testListMap = do
  print "******* listMap"
  quickCheck $ counterexample "add" $ listMap (+) 5 [1, 2, 3] == [6, 7, 8]
  quickCheck $ counterexample "sub" $ listMap (-) 5 [1, 2, 3] == [4, 3, 2]
  quickCheck $ counterexample "mul" $ listMap (*) 5 [1, 2, 3] == [5, 10, 15]
  quickCheck $ counterexample "empty" $ listMap (-) 5 [] == []

---------------------------------- member -------------------------------
-- #3: 10-points
-- Use foldl to implement member e list which returns True iff
-- e is a member of list.  Must use foldl, cannot use elem
-- Hint: define folding function using a lambda or local let/where definition;
-- also see definition of member in slides.
member :: Eq a => a -> [a] -> Bool

member e list = foldl (\acc x -> acc || (x == e)) False list

testMember = do
  print "******* member"
  quickCheck $ counterexample "ints first" $  member 5 [ 5, 7, 2 ] == True
  quickCheck $ counterexample "ints last" $  member 2 [ 5, 7, 2 ] == True
  quickCheck $ counterexample "ints mid" $  member 7 [ 5, 7, 2 ] == True
  quickCheck $ counterexample "ints fail" $  member 4 [ 5, 7, 2 ] == False
  quickCheck $ counterexample "empty" $  member 4 [] == False


------------------------ Functions in Separate Files --------------------

-- #4: 15-points
-- implement the specified function in EvalIntExpr.hs

-- #5: 20-points
-- implement the specified function in EvalIdExpr.hs

-- #6: 20-points
-- implement the specified function in EvalMaybeExpr.hs

-- #7: 25-points
-- implement the specified function in PostfixExpr.hs

--------------------------------- Tests ---------------------------------

-- Can mark test suites with following test statuses:
--   Only:  run only these tests and other tests marked Only.
--   Run:   run these tests when no tests are marked Only.
--   Skip:  skip these tests.
allTests = [
    (Run testToSingletonLists),
    (Run testListMap),
    (Run testMember),
    (Run testEvalIntExpr),
    (Run testEvalIdExpr),
    (Run testEvalMaybeExpr),
    (Run testPostfixExpr)
  ]


main = do
  mapM_ id tests
  where
    only = onlyTests allTests
    tests = if (length only > 0) then only else runTests allTests
  
