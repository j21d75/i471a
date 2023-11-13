module EvalIdExpr ( evalIdExpr, testEvalIdExpr ) where

import Test.QuickCheck
import Data.List (lookup)
data IdExpr =
  Id String |
  Leaf Int |
  Add IdExpr IdExpr |
  Sub IdExpr IdExpr |
  Mul IdExpr IdExpr |
  Uminus IdExpr
  deriving (Eq, Show)

type Assoc a = [ (String, a) ]

-- return evaluation of expr, looking up id's in assoc.  If an
-- id is not found in assoc, then its value should default to 0.
-- Hint: use Data.List.assoc imported above.
evalIdExpr :: IdExpr -> Assoc Int -> Int

--evalIdExpr expr assoc = error "TODO"

evalIdExpr (Leaf expr) assoc = expr                       

evalIdExpr (Id expr) assoc = case lookup expr assoc of
    Just val -> val
    Nothing -> 0
                                                                                                 
evalIdExpr (Add e1 e2) assoc = evalIdExpr e1 assoc + evalIdExpr e2 assoc                                      
                                                                                                  
evalIdExpr (Sub e1 e2) assoc = evalIdExpr e1 assoc - evalIdExpr e2 assoc                                       
                                                                                                  
evalIdExpr (Mul e1 e2) assoc = evalIdExpr e1 assoc * evalIdExpr e2 assoc                                      
                                                                                                  
evalIdExpr (Uminus e1) assoc = - evalIdExpr e1 assoc    


testEvalIdExpr = do
  print "*** test evalIdExpr"
  -- unit tests
  quickCheck $ counterexample "Leaf" $ evalIdExpr (Leaf 42) [] == 42
  quickCheck $ counterexample "Add" $
    evalIdExpr (Add (Leaf 33) (Leaf 22)) [] == 55
  quickCheck $ counterexample "Sub" $
    evalIdExpr (Sub (Leaf 33) (Leaf 22)) [] == 11
  quickCheck $ counterexample "Mul" $
    evalIdExpr (Mul (Leaf 31) (Leaf 4)) [] == 124
  quickCheck $ counterexample "Uminus" $
    evalIdExpr (Uminus (Leaf 33)) [] == (-33)
  quickCheck $ counterexample "Complex" $
    evalIdExpr (Mul (Leaf 4)
                 (Sub (Add (Leaf 3) (Uminus (Leaf 33)))
                   (Leaf 20))) [] == (-200)

  -- id unit tests
  quickCheck $ counterexample "ok id lookup" $
    evalIdExpr (Id "a") [("a", 42)] == 42
  quickCheck $ counterexample "fail id lookup" $
    evalIdExpr (Id "a") [("b", 42)] == 0
  quickCheck $ counterexample "id lookup: a: ok, b: fail" $
    evalIdExpr (Add (Id "a") (Id "b")) [("a", 42)] == 42
  quickCheck $ counterexample "id lookup: a: ok, b: ok" $
    evalIdExpr (Add (Id "a") (Id "b")) [("a", 42), ("b", 22)] == 64
  quickCheck $ counterexample "complex id lookup" $
    evalIdExpr (Mul (Id "a")
                 (Sub (Add (Id "b") (Uminus (Id "c")))
                   (Id "d")))
               [("a", 4), ("b", 3), ("c", 33), ("d", 20)] == (-200)

  -- property-based tests
  -- id lookup
  quickCheck $ counterexample "random id lookup ok" $
    (\ id1 val1 -> evalIdExpr (Id id1) [(id1, val1)] == val1)
  quickCheck $ counterexample "random id lookup fail" $
    (\ id1 val1 -> evalIdExpr (Id id1) [(id1 ++ "x", val1)] == 0)
  
  -- property-based tests
  -- commutativity
  quickCheck $ counterexample "e1 + e2 == e2 + e1" $
    (\ e1 e2 -> 
        evalIdExpr (Add (Leaf e1) (Leaf e2)) [] ==
        evalIdExpr (Add (Leaf e2) (Leaf e1)) [])
  quickCheck $ counterexample "e1 * e2 == e2 * e1" $
    (\ e1 e2 -> 
        evalIdExpr (Mul (Leaf e1) (Leaf e2)) [] ==
        evalIdExpr (Mul (Leaf e2) (Leaf e1)) [])
  -- associativity
  quickCheck $ counterexample "(e1 + e2) + e3 == e1 + (e2 + e3)" $
    (\ e1 e2 e3 -> 
        evalIdExpr (Add (Add (Leaf e1) (Leaf e2)) (Leaf e3)) [] ==
        evalIdExpr (Add (Leaf e1) (Add (Leaf e2) (Leaf e3))) [])
  quickCheck $ counterexample "(e1 * e2) * e3 == e1 * (e2 * e3)" $
    (\ e1 e2 e3 ->
        evalIdExpr (Mul (Mul (Leaf e1) (Leaf e2)) (Leaf e3)) [] ==
        evalIdExpr (Mul (Leaf e1) (Mul (Leaf e2) (Leaf e3))) [])

  -- subtraction
  quickCheck $ counterexample "e1 - e2 = -1*(e2 - e1)" $
    (\ e1 e2 ->
        evalIdExpr (Sub (Leaf e1) (Leaf e2)) [] ==
        evalIdExpr (Mul (Leaf (-1)) (Sub (Leaf e2) (Leaf e1))) [])

  -- distributivity
  quickCheck $ counterexample "e1 * (e2 + e3) == e1*e2 + e1*e3" $
    (\ e1 e2 e3 -> 
        evalIdExpr (Mul (Leaf e1) (Add (Leaf e2) (Leaf e3))) [] ==
        evalIdExpr (Add (Mul (Leaf e1) (Leaf e2)) 
                     (Mul (Leaf e1) (Leaf e3))) [])
  quickCheck $ counterexample "e1 * (e2 - e3) == e1*e2 - e1*e3" $
    (\ e1 e2 e3 -> 
        evalIdExpr (Mul (Leaf e1) (Sub (Leaf e2) (Leaf e3))) [] ==
        evalIdExpr (Sub (Mul (Leaf e1) (Leaf e2))  
                      (Mul (Leaf e1) (Leaf e3))) [])
  

