quadratic_roots2(A, B, C, Z):-
    Dis is B*B - 4*A*C,
    q_helper(A, B, Dis, Z).

q_helper(A, B, Dis, Z):-
    Z is ((0-B) + sqrt(Dis))/(2*A).

q_helper(A, B, Dis, Z):-
    Z is ((0-B) - sqrt(Dis))/(2*A).

quadratic_roots(A, B, C, Z):-
    Z is ((0-B) + sqrt(B*B - 4*A*C))/(2*A).

quadratic_roots(A, B, C, Z):-
    Z is ((0-B) - sqrt(B*B - 4*A*C))/(2*A).

sum_lengths([], 0).
    sum_lengths([N|Ns], Sum):-
        length(N, Len),
        sum_lengths(Ns, NsLen),
        Sum is Len + NsLen.

sum_list([], 0).
    sum_list([N|Ns], Sum):-
      sum_list(Ns, NsSum),
      Sum is N + NsSum.
