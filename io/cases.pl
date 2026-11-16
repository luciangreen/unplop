:- module(cases, [title/1, case/3]).
:- use_module('../prolog/unplop').
:- use_module(engine).
title('unplop').
word_g(N, W) :- length(W, N), maplist([X]>>rnd_int(0, 25, X), W).
algo_g(N, A) :- rnd_int(1, 25, D), R is 1 + D mod max(1, N - 1), rnd_pick([identity, reverse, rotate(R), caesar(D), noise], A).
exs_g(A, N, Exs) :- rnd_int(2, 4, K), length(Exs, K), maplist([I-O]>>( word_g(N, I), ( A == noise -> word_g(N, O) ; apply_whole(A, I, O) ) ), Exs).
case(unplop, [Exs], unplop) :- rnd_int(2, 5, N), algo_g(N, A), exs_g(A, N, Exs).
case(per_char, [Exs], per_char_or_none) :- rnd_int(1, 4, N), algo_g(N, A), exs_g(A, N, Exs).
case(apply_whole, [A, W], apply_whole) :- rnd_int(1, 6, N), algo_g(N, A0), ( A0 == noise -> A = constant([1,2]) ; A = A0 ), word_g(N, W).
case(whole, [Ps, N], whole) :- rnd_int(1, 4, N), rnd_pick([id, rev, mix], K), numlist(1, N, Ks),
    maplist([I0, P]>>( I is I0 - 1, ( K == id -> P = in(I) ; K == rev -> J is N - I0, P = in(J) ; rnd_int(0, 3, J), P = shift(J, 2) ) ), Ks, Ps).
per_char_or_none(Exs, P) :- ( per_char(Exs, P0) -> P = P0 ; P = none ).
