#!/usr/bin/env racket

#lang racket
(require rackunit)

;;Exercise 1: 25-points
;;Given a scheme expr defined by the following grammar:
;; expr
;;  : NUMBER
;;  | ( 'add expr expr )
;;  | ( 'sub expr expr )
;;  | ( 'mul expr expr )
;;  | ( 'uminus expr )
;;  ;
;;
;; where the parentheses denote the parentheses around scheme lists.
;;
;; Implement a function (eval-expr expr) which evaluates an expr
;; of the above form with 'add corresponding to binary +, 'sub to
;; binary -, 'mul to binary * and 'uminus to unary -.
;;
;; *Hint*: use number? and equal? along with list accessor functions

(define (eval-expr1 expr)
 (cond 
   ((number? expr)
    expr)
   ((equal? 'add (car expr))
    (+ (eval-expr1(list-ref expr 1)) (eval-expr1(list-ref expr 2))))
   ((equal? 'mul (car expr))
    (* (eval-expr1(list-ref expr 1)) (eval-expr1(list-ref expr 2))))
   ((equal? 'sub (car expr))
    (- (eval-expr1(list-ref expr 1)) (eval-expr1(list-ref expr 2))))
   ((equal? 'uminus (car expr))
    (- (eval-expr1(list-ref expr 1))))
  ))   
	 
(check-equal? (eval-expr1 42) 42)
(check-equal? (eval-expr1 '(add 20 22)) 42)
(check-equal? (eval-expr1 '(mul 14 3)) 42)
(check-equal? (eval-expr1 '(uminus -42)) 42)
(check-equal? (eval-expr1 '(add (mul 9 4) (mul 2 3))) 42)
(check-equal? (eval-expr1 '(add (mul 9 4) (mul 2 (uminus 3)))) 30)


;; Exercise 2: 25-points
;; Given a scheme expr as in exercise 1, compile it into scheme;
;; i.e. replace, add with '+, mul with '* and sub/uminus with '-.
;;
;; *Hint*: use list to build lists
(define (compile-expr1 expr)
 (cond 
   ((number? expr)
    expr)
   ((equal? 'add (car expr))
    (list '+ (compile-expr1(list-ref expr 1)) (compile-expr1(list-ref expr 2))))
   ((equal? 'mul (car expr))
    (list '* (compile-expr1(list-ref expr 1)) (compile-expr1(list-ref expr 2))))
   ((equal? 'sub (car expr))
    (list '- (compile-expr1(list-ref expr 1)) (compile-expr1(list-ref expr 2))))
   ((equal? 'uminus (car expr))
    (list '- (compile-expr1(list-ref expr 1)))
  )))   

(check-equal? (compile-expr1 42) 42)
(check-equal? (compile-expr1 '(add 20 22)) '(+ 20 22))
(check-equal? (compile-expr1 '(mul 14 3)) '(* 14 3))
(check-equal? (compile-expr1 '(uminus -42)) '(- -42))
(check-equal? (compile-expr1 '(add (mul 9 4) (mul 2 3)))
	      '(+ (* 9 4) (* 2 3)))
(check-equal? (compile-expr1 '(add (mul 9 4) (mul 2 (uminus 3))))
	      '(+ (* 9 4) (* 2 (- 3))))

;; note that we need to tell eval to use the base namespace
;; when using eval within a function
(define (eval-in-fn expr) (eval expr (make-base-namespace)))

;; it is possible to evaluate the compiled expressions using eval.
(check-equal? (eval-in-fn (compile-expr1 42)) 42)
(check-equal? (eval-in-fn (compile-expr1 '(add 20 22))) 42)
(check-equal? (eval-in-fn (compile-expr1 '(mul 14 3))) 42)
(check-equal? (eval-in-fn (compile-expr1 '(uminus -42))) 42)
(check-equal? (eval-in-fn (compile-expr1 '(add (mul 9 4) (mul 2 3)))) 42)
(check-equal? (eval-in-fn (compile-expr1 '(add (mul 9 4) (mul 2 (uminus 3)))))
	      30)


;;Exercise 3: 25-points
;;Given a scheme expr defined by the following grammar:
;; expr
;;  : NUMBER
;;  | SYMBOL
;;  | ( 'add expr expr )
;;  | ( 'sub expr expr )
;;  | ( 'mul expr expr )
;;  | ( 'uminus expr )
;;  ;
;;
;; where the parentheses denote the parentheses around scheme lists.
;;
;; Implement a function (eval-expr2 expr env) which evaluates an expr
;; of the above form with 'add corresponding to binary +, 'sub to
;; binary -, 'mul to binary * and 'uminus to unary -.  A SYMBOL
;; is evaluated by looking it up in the association list env which
;; consists of (SYMBOL NUMBER) pairs.  If a SYMBOL is not found
;; in env, then it should call (error SYMBOL "undefined")
;;
;; *Hint*: use assoc and symbol?.

(define (eval-expr2 expr env)
 (cond 
   ((number? expr)
    expr)
   ((symbol? expr)
    (if (assoc expr env)
    (list-ref (assoc expr env) 1)
    (error expr "undefined")))
   ((equal? 'add (car expr))
    (+ (eval-expr2(list-ref expr 1) env) (eval-expr2(list-ref expr 2) env)))
   ((equal? 'mul (car expr))
    (* (eval-expr2(list-ref expr 1) env) (eval-expr2(list-ref expr 2) env)))
   ((equal? 'sub (car expr))
    (- (eval-expr2(list-ref expr 1) env) (eval-expr2(list-ref expr 2) env)))
   ((equal? 'uminus (car expr))
    (- (eval-expr2(list-ref expr 1) env)))
   ))
   
(check-equal? (eval-expr2 42 '()) 42)
(check-equal? (eval-expr2 '(add 20 22) '()) 42)
(check-equal? (eval-expr2 '(mul 14 3) '()) 42)
(check-equal? (eval-expr2 '(uminus -42) '()) 42)
(check-equal? (eval-expr2 '(add (mul 9 4) (mul 2 3)) '()) 42)

(check-equal? (eval-expr2 'a '((a 42))) 42)
(check-equal? (eval-expr2 '(add a a) '((a 22))) 44)
(check-exn exn:fail? (lambda () (eval-expr2 '(add a b) '((a 22)))))
(check-equal? (eval-expr2 '(mul a b) '((b 14) (a 3))) 42)
(check-equal? (eval-expr2 '(uminus x) '((x 42))) -42)
(check-equal? (eval-expr2 '(add (mul a b) (mul c 3))
			  '((a 9) (b 4) (c 2))) 42)

;; Exercise 4: 25-points
;; Like compile-expr1, but allow env lookup for SYMBOL's as in eval-expr2.
;; Compile into a suitable let expression, using an auxiliary function
;; similar to compile-expr1

(define (compile-expr2 expr env)
  (list 'let env (ex4help expr env)))

(define (ex4help expr env)
 (cond 
   ((number? expr)
    expr)
   ((symbol? expr)
    expr)
   ((equal? 'add (car expr))
    (list '+ (ex4help(list-ref expr 1) env) (ex4help(list-ref expr 2) env)))
   ((equal? 'mul (car expr))
    (list '* (ex4help(list-ref expr 1) env) (ex4help(list-ref expr 2) env)))
   ((equal? 'sub (car expr))
    (list '- (ex4help(list-ref expr 1) env) (ex4help(list-ref expr 2) env)))
   ((equal? 'uminus (car expr))
    (list '- (ex4help(list-ref expr 1) env))
  )))   

(check-equal? (compile-expr2 'a '((a 42))) '(let ((a 42)) a))
(check-equal? (compile-expr2 '(add a a) '((a 22))) '(let ((a 22)) (+ a a)))
(check-equal? (compile-expr2 '(add a b) '((a 22))) '(let ((a 22)) (+ a b)))
(check-equal? (compile-expr2 '(mul a b) '((b 14) (a 3)))
	      '(let ((b 14) (a 3)) (* a b)))
(check-equal? (compile-expr2 '(uminus x) '((x 42))) '(let ((x 42)) (- x)))
(check-equal? (compile-expr2 '(add (mul a b) (mul (uminus c) 3))
			     '((a 9) (b 4) (c 2)))
	      '(let ((a 9) (b 4) (c 2)) (+ (* a b) (* (- c) 3))))

;;can evaluate compiled expressions
(check-equal? (eval-in-fn (compile-expr2 'a '((a 42)))) 42)
(check-equal? (eval-in-fn (compile-expr2 '(add a a) '((a 22)))) 44)
(check-exn exn:fail?
	   (lambda () (eval-in-fn (compile-expr2 '(add a b) '((a 22))))))
(check-equal? (eval-in-fn (compile-expr2 '(mul a b) '((b 14) (a 3)))) 42)
(check-equal? (eval-in-fn (compile-expr2 '(uminus x) '((x 42)))) -42)
(check-equal? (eval-in-fn (compile-expr2 '(add (mul a b) (mul (uminus c) 3))
					 '((a 9) (b 4) (c 2))))
	      30)










