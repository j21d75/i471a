(define (quadratic-roots a b c (fn sqrt))
  (if (= a 0)
    (display "error")
  (let ((dis (fn (- (expt b 2) (* 4 a c)))))
  (list (/ (+ (- b) dis) (* 2 a)) (/ (- (- b) dis) (* 2 a)))
  )))

(define (cmp-gt ls1 ls2)
   (if (null? ls1)
       '()
       (cons (> (car ls1) (car ls2))
            (cmp-gt (cdr ls1) (cdr ls2)))))


(define (ls-prod ls1 ls2)
   (if (null? ls1)
       '()
       (cons (* (car ls1) (car ls2))
            (ls-prod (cdr ls1) (cdr ls2)))))

(define ls-f
      (lambda (ls1 ls2 (fn (lambda (a b) (+ a b))))
        (if (null? ls1)
          `()
       (cons (fn (car ls1) (car ls2))
            (ls-f (cdr ls1) (cdr ls2) fn)))))

(define (greater-than ls1 (v 0))
   (if (null? ls1)
       '()
       (cons (> (car ls1) v)
            (greater-than (cdr ls1) v))))

(define (my-sqrt n (guess 1.0))
  (if (<= (abs (- (* guess guess) n)) (* n .0001))
    guess
    (my-sqrt n (/ (+ guess (/ n guess)) 2))))
