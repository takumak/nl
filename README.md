# nl

## How to use

```
% make '(add 1 2 3 (mul 4 5) (sub 6 7))'
25
```

```
% time make '(call (lambda (f) (call f f 10)) (lambda (f c) (if (not (eq c 1)) (call f f (sub c 1))) (print c)))'
1
2
3
4
5
6
7
8
9
10
make   2.11s user 0.03s system 99% cpu 2.154 total
```

```
% make '(call (lambda (f) (let ((a 10)) (call f))) (lambda () (print a)))'
makefile:10: *** undefined variable - "a".  Stop.
% make '(let ((a 1)) (call (lambda (f) (let ((a 2)) (call f))) (lambda () (print a))) )'
1
```

```
% time make "$(cat fib.nl | tr -d '\n')"
(list 0 1 1 2 3 5 8 13 21 34)
make "$(cat fib.nl | tr -d '\n')"  4.02s user 0.00s system 99% cpu 4.023 total
```

## License

The MIT License <http://opensource.org/licenses/MIT>
