% unplop: plop2 in reverse. plop2 writes one program per output character; unplop takes
% examples, learns each character's program, then looks for the one whole algorithm that
% explains every character (identity, reverse, rotate, a Caesar shift, a constant), so
% per-character code can be folded back into short readable code.
% Strings are lists of letter numbers 0..25; examples are Input-Output pairs of equal length.
%?- per_char([[1,2,3]-[3,2,1], [4,5,6]-[6,5,4]], P).      % P = [in(2), in(1), in(0)]
%?- whole([in(2), in(1), in(0)], 3, W).                   % W = reverse
%?- unplop([[0,1,2]-[1,2,3], [5,6,7]-[6,7,8]], W).        % W = caesar(1)
%?- apply_whole(rotate(1), [1,2,3], Out).                 % Out = [2,3,1]
:- module(unplop, [per_char/2, char_programs/3, whole/3, unplop/2, apply_whole/3, apply_char/3]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% A character's program: in(I) copies input I; shift(I, D) adds D (mod 26) to input I; const(C).
apply_char(in(I), In, C) :- nth0(I, In, C).
apply_char(shift(I, D), In, C) :- nth0(I, In, X), C is (X + D) mod 26.
apply_char(const(C), _, C).

% char_programs(+Examples, +K, -Programs): every program that gives character K in all examples,
% simplest first (const, then in, then shift).
char_programs(Exs, K, Ps) :-
    Exs = [In0-_|_], length(In0, N), Top is N - 1,
    findall(P, ( candidate(Top, P), forall(member(In-Out, Exs), ( nth0(K, Out, C), apply_char(P, In, C) )) ), Ps0),
    Ps = Ps0.
candidate(_, const(C)) :- between(0, 25, C).
candidate(Top, in(I)) :- between(0, Top, I).
candidate(Top, shift(I, D)) :- between(0, Top, I), between(1, 25, D).

% per_char(+Examples, -Programs): the simplest program for each output character (fails if one has none).
per_char(Exs, Ps) :- Exs = [_-Out0|_], length(Out0, N), Top is N - 1,
    findall(P, ( between(0, Top, K), char_programs(Exs, K, [P|_]) ), Ps0), length(Ps0, N), Ps = Ps0.

% whole(+Programs, +N, -Whole): the whole algorithm the per-character programs add up to.
whole(Ps, N, W) :- whole_(Ps, N, W0), !, W = W0.
whole(_, _, per_char).
whole_(Ps, N, identity) :- numlist0(N, Is), maplist([I, in(I)]>>true, Is, Ps).
whole_(Ps, N, reverse) :- numlist0(N, Is), reverse(Is, Rs), maplist([I, in(I)]>>true, Rs, Ps).
whole_(Ps, N, rotate(D)) :- N > 1, between(1, N, D0), D is D0 mod N, D > 0, numlist0(N, Is), maplist([K, in(I)]>>(I is (K + D) mod N), Is, Ps).
whole_(Ps, N, caesar(D)) :- between(1, 25, D), numlist0(N, Is), maplist([I, shift(I, D)]>>true, Is, Ps).
whole_(Ps, _, constant(Cs)) :- maplist([const(C), C]>>true, Ps, Cs).
numlist0(N, Is) :- N > 0, Top is N - 1, numlist(0, Top, Is).

% unplop(+Examples, -Whole): learn the per-character programs, then fold them into one.
% Each whole algorithm is tried against the examples first, simplest first (so a character that the
% examples happen to keep constant, such as a shared first letter, cannot hide identity); only if none
% fits are the simplest per-character programs folded as before.
unplop(Exs, W) :- ( per_char(Exs, Ps) -> Exs = [In-_|_], length(In, N),
        ( whole_candidate(N, Exs, W0), forall(member(I-O, Exs), apply_whole(W0, I, O)) -> W = W0 ; whole(Ps, N, W) ) ; W = none ).
whole_candidate(_, _, identity).
whole_candidate(_, _, reverse).
whole_candidate(N, _, rotate(D)) :- N > 1, Top is N - 1, between(1, Top, D).
whole_candidate(_, _, caesar(D)) :- between(1, 25, D).
whole_candidate(_, [_-O|_], constant(O)).

% apply_whole(+Whole, +Input, -Output)
apply_whole(identity, In, Out) :- Out = In.
apply_whole(reverse, In, Out) :- reverse(In, Out).
apply_whole(rotate(D), In, Out) :- length(In, N), numlist0(N, Ks), maplist([K, C]>>(I is (K + D) mod N, nth0(I, In, C)), Ks, Out).
apply_whole(caesar(D), In, Out) :- maplist([X, Y]>>(Y is (X + D) mod 26), In, Out).
apply_whole(constant(Cs), _, Cs).
