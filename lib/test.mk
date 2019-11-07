# License: MIT

#assert=@(test "$2" = "$3" && echo '$1 = "$2"') || \
#(echo '$1 should be "$3" but got "$2"' && false)
assert=@(test "$2" = "$3" && echo -n .) || \
(echo && echo '$1 should be "$3" but got "$2"' && false)
test0=$(call assert,$1(),$(call $1),$2)
test1=$(call assert,$1($2),$(call $1,$2),$3)
test2=$(call assert,$1($2,$3),$(call $1,$2,$3),$4)
test3=$(call assert,$1($2,$3,$4),$(call $1,$2,$3,$4),$5)
