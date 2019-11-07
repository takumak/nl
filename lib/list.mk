# License: MIT

# requires: base.mk arithmetic.mk

# $1: word list
# returns: first word of $1
first=$(word 1,$1)

# $1: word list
# returns: last word of $1
last=$(word $(words $1),$1)

# $1: word list
# returns: $1 without first one
rest=$(wordlist 2,$(words $1),$1)

# $1: word list
# returns: $1 without last one
chop=$(wordlist 1,$(call decr,$(words $1)),$1)

# $1: word list
# $2: start index (starts from 1; can be negative number)
# $3: end index (optional; inclusive; can be negative number; -1 is last word)
# example:
#   $(call slice,1 2 3 4,2 3) => 2 3
#   $(call slice,1 2 3 4,2) => 2 3 4
#   $(call slice,1 2 3 4,-2) => 3 4
slice=$(strip $(if \
  $(call lt,$2,0), \
  $(call slice,$1,$(call incr,$(call add,$2,$(words $1))),$3), \
  $(if $(call lt,$3,0), \
       $(call slice,$1,$2,$(call incr,$(call add,$3,$(words $1)))), \
       $(wordlist $2,$3,$1)) \
))

# internal function
seq2=$(if $(call ge,$2,$1),$(or $(and $(call eq,$2,$1),$1),$(call seq2,$1,$(call decr,$2)) $2))

# $1: start number
# $2: end number (optional; inclusive)
# if $2 is not supplied, $1 means end number
# example:
#   $(call seq,5) => 1 2 3 4 5
#   $(call seq,-2,2) => -2 -1 0 1 2
seq=$(if $2,$(call seq2,$1,$2),$(call seq2,1,$1))

# $1: word list
# $2: callback function
# callback arguments:
#   $1: a word from $3
#   $2: index of $1 ($1 == $(word $2,$3))
#   $3: target word list
# example:
#   func=$(call add,$1,3)
#   $(call map,1 2 3,func) => 4 5 6
map=$(foreach i,$(call seq,$(words $1)),$(call $2,$(word $i,$1),$i,$1))
