# unplop

plop2 in reverse. plop2 writes one program per output character; unplop takes examples, learns each character's program, then looks for the one whole algorithm that explains every character (identity, reverse, rotate, a Caesar shift, a constant), so per-character code can be folded back into short readable code. Strings are lists of letter numbers 0..25; examples are Input-Output pairs of equal length.

## Use

```prolog
?- use_module(prolog/unplop).
?- per_char([[1,2,3]-[3,2,1], [4,5,6]-[6,5,4]], P).      % P = [in(2), in(1), in(0)]
?- whole([in(2), in(1), in(0)], 3, W).                   % W = reverse
?- unplop([[0,1,2]-[1,2,3], [5,6,7]-[6,7,8]], W).        % W = caesar(1)
?- apply_whole(rotate(1), [1,2,3], Out).                 % Out = [2,3,1]
```

## Proofs

`proofs/theorems.pl` proves 5 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every whole algorithm on strings of length 1..3, applied to every string over letters 0..3.

1. Sound: whatever whole algorithm unplop finds gives every example's output.
2. Complete: from all examples of a whole algorithm, unplop finds an algorithm that agrees with it everywhere.
3. Each learned character program gives that character in every example.
4. A whole algorithm and its per-character programs agree on every input (folding loses nothing).
5. unplop and apply_whole are steadfast.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
