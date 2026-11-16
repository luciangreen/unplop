% Theorems about unplop, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module('../prolog/unplop').
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).

% Domain: every whole algorithm on strings of length 1..3, applied to every string over letters 0..3.
word(N, W) :- length(W, N), maplist([X]>>between(0, 3, X), W).
algo(N, A) :- member(A, [identity, reverse]) ; ( N > 1, between(1, 2, D), D < N, A = rotate(D) ) ; ( member(D, [1, 7, 25]), A = caesar(D) ).
examples(A, N, Exs) :- findall(W-O, ( word(N, W), apply_whole(A, W, O) ), Exs).

% 1. Sound: whatever whole algorithm unplop finds gives every example's output.
theorem(found_algorithm_explains_every_example) :-
    forall(( between(1, 3, N), algo(N, A), examples(A, N, Exs) ),
           ( unplop(Exs, W), forall(member(I-O, Exs), apply_whole(W, I, O)) )).

% 2. Complete: from all examples of a whole algorithm, unplop finds an algorithm that agrees with it everywhere.
theorem(recovers_the_algorithm) :-
    forall(( between(1, 3, N), algo(N, A), examples(A, N, Exs) ),
           ( unplop(Exs, W), W \== none, W \== per_char, forall(word(N, X), ( apply_whole(A, X, Y), apply_whole(W, X, Y) )) )).

% 3. Each learned character program gives that character in every example.
theorem(char_programs_are_correct) :-
    forall(( between(1, 3, N), algo(N, A), examples(A, N, Exs), per_char(Exs, Ps), nth0(K, Ps, P) ),
           forall(member(I-O, Exs), ( nth0(K, O, C), apply_char(P, I, C) ))).

% 4. A whole algorithm and its per-character programs agree on every input (folding loses nothing).
theorem(whole_agrees_with_its_characters) :-
    forall(( between(1, 3, N), algo(N, A), examples(A, N, Exs), per_char(Exs, Ps), whole(Ps, N, W), W \== per_char, word(N, X) ),
           ( apply_whole(W, X, Y), forall(nth0(K, Ps, P), ( nth0(K, Y, C), apply_char(P, X, C) )) )).

% 5. unplop and apply_whole are steadfast.
theorem(steadfast) :-
    forall(( between(1, 2, N), algo(N, A), examples(A, N, Exs), member(G, [identity, reverse, caesar(1), none, per_char]) ),
           iff(unplop(Exs, G), ( unplop(Exs, W), W == G ))).
