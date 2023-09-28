#!/usr/bin/env racket

#lang racket
(require rackunit)

;;Exercise 1
;;Given a proper-list list of proper-lists, return the sum of the
;;lengths of all the top-level contained lists.
(define (sum-lengths ls)
  (if (null? ls)
    0
   (+ (length (car ls)) (sum-lengths (cdr ls))
  )))

(check-equal? (sum-lengths '()) 0)
(check-equal? (sum-lengths '(() ())) 0)
(check-equal? (sum-lengths '((1 2) (2 1))) 4)
(check-equal? (sum-lengths '((1 ((2)) 3) ((2 1)))) 4)

;;Repeat previous exercise where all recursion is tail-recursive
(define (sum-lengths-tr ls (sum 0))
  (if (null? ls)
    sum
   (let ((sum2 (+ (length (car ls)) sum)))
   (sum-lengths-tr (cdr ls) sum2)
  )))

(check-equal? (sum-lengths-tr '()) 0)
(check-equal? (sum-lengths-tr '(() ())) 0)
(check-equal? (sum-lengths-tr '((1 2) (2 1))) 4)
(check-equal? (sum-lengths-tr '((1 ((2)) 3) ((2 1)))) 4)

;;Evaluate polynomial given by list coeffs at x; i.e. return
;; coeffs[0] + coeffs[1]*x + coeffs[2]*x^2 + ...
;; all recursion should be tail-recursive
(define (poly-eval x coeffs (sum 0) (power 0))
  (if (null? coeffs)
    sum
    (let ((sum2 (+ (+ (* (car coeffs) (expt x power)) sum))))
      (let ((power2 (+ power 1)))
        (poly-eval x (cdr coeffs) sum2 power2)
  ))))

(check-equal? (poly-eval 2 '()) 0)
(check-equal? (poly-eval 2 '(5)) 5)
(check-equal? (poly-eval 2 '(5 3)) 11)
(check-equal? (poly-eval 2 '(5 3 -3)) -1)
(check-equal? (poly-eval -1 '(5 3 -3)) -1)
(check-equal? (poly-eval -1 '(5 3 -3 5)) -6)

;;Exercise 2

;;(ls-prod ls1 ls2): given proper lists of numbers ls1 and ls2 having
;;the same length, return list containing product of individual
;;elements of list ls1 and ls2.
;;Cannot use recursion
(define (ls-prod ls1 ls2)
  (map * ls1 ls2)
  )

(check-equal? (ls-prod '(2 3) '(4 5)) '(8 15))
(check-equal? (ls-prod '() '()) '())

;;(ls-f ls1 ls2 f): given proper lists of numbers ls1 and ls2 having
;;the same length and a binary function f, return list containing f
;;applied to individual elements of ls1 and ls2.
;;Cannot use recursion
(define (ls-f ls1 ls2 f)
  (map (lambda (a b) (f a b)) ls1 ls2)
  )

(check-equal? (ls-f '(2 3) '(4 5) (lambda (a b) (* a b))) '(8 15))
(check-equal? (ls-f '(2 3) '(4 6) (lambda (a b) (- b a))) '(2 3))
(check-equal? (ls-f '(2 3) '(4 6) (lambda (a b) a)) '(2 3))
(check-equal? (ls-f '() '() (lambda (a b) a)) '())

;;(greater-than ls val) should return a boolean list containing the same
;;# of elements as ls, with an entry being #t iff the corresponding element
;;in ls is greater-than val (which should default to 0).
;;Cannot use recursion.
(define (greater-than ls (val 0))
  (map (lambda (a) (> a val)) ls)
  )

(check-equal? (greater-than '(1 2 3 4) 2) '(#f #f #t #t))
(check-equal? (greater-than '(-1 2 0 1)) '(#f #t #f #t))
(check-equal? (greater-than '() 3) '())

;;(greater-thans ls val) should return a list containing those elements
;;of ls which are greater-than val (which should default to 0).
;;Cannot use recursion.
(define (greater-thans ls (val 0))
  (filter (lambda (a) (> a val)) ls)
  )

(check-equal? (greater-thans '(1 2 3 4) 2) '(3 4))
(check-equal? (greater-thans '(-1 2 0 1)) '(2 1))
(check-equal? (greater-thans '() 3) '())


;;(count-greater-thans ls val) should return the # of elements
;;of ls which are greater-than val (which should default to 0).
;;Must use foldl; cannot use recursion or filter.
(define (count-greater-thans ls (val 0))
  (foldl (lambda (a acc) (if (> a val) (+ 1 acc) acc)) 0 ls)
  )

(check-equal? (count-greater-thans '(1 2 3 4) 2) 2)
(check-equal? (count-greater-thans '(-1 2 0 1)) 2)
(check-equal? (count-greater-thans '() 3) 0)







