# License: MIT

# requires: none

comma=,
space=
space+=
lbracket=(
rbracket=)

join-with=$(subst $(space),$2,$1)

# $1: any string
# returns:
#   "t" if $1 is not empty
#   "" if $1 is empty
bool=$(if $1,t,)

# $1: any string
# returns:
#   "" if $1 is not empty
#   "t" if $1 is empty
not=$(if $1,,t)

# $1: a word
# $2: a word
# returns:
#   "t" if $1 == $2
#   "" if $1 != $2
eq=$(and $(call not,$(2:$1=)),$(call not,$(1:$2=)))

# $1: a word
# $2: a word
# returns:
#   "" if $1 == $2
#   "t" if $1 != $2
ne=$(call not,$(call eq,$1,$2))

# $1: a word
# $2: a word
# returns:
#   "t" if $1 is ends with $2
#   "" if $1 is not ends with $2
tail-is=$(call ne,$1,$(1:$2=))
