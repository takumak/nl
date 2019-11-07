# License: MIT

# requires: base.mk

# $1: a word
# returns: a number character ([0-9]) that $1 trailing
# if $1 is not ends with number characters,
# this throws an error and make will stops
get-tail-digit=$(strip \
$(if $(call tail-is,$1,0),0,\
$(if $(call tail-is,$1,1),1,\
$(if $(call tail-is,$1,2),2,\
$(if $(call tail-is,$1,3),3,\
$(if $(call tail-is,$1,4),4,\
$(if $(call tail-is,$1,5),5,\
$(if $(call tail-is,$1,6),6,\
$(if $(call tail-is,$1,7),7,\
$(if $(call tail-is,$1,8),8,\
$(if $(call tail-is,$1,9),9,\
$(error non-number character detected))))))))))))

# $1: a word
# returns: a word without a trailing number character
# if $1 is not ends with number characters,
# this throws an error and make will stops
strip-tail-digit=$(1:$(call get-tail-digit,$1)=)

# $1: a word
# returns:
#   "t" if $1 is starts with "-"
#   "" if $1 is not starts with "-"
is-negative=$(call ne,$1,$(patsubst -%,%,$1))

# $1: a word
# returns:
#   "$1" if $1 == 0 or $1 is starts with "-"
#   "-$1" if $1 != 0 and $1 is not starts with "-"
negative=$(if $(call is-negative,$1),$(patsubst -%,%,$1),$(and $(call ne,$1,0),-)$1)

n0=
n1=x
n2=x x
n3=x x x
n4=x x x x
n5=x x x x x
n6=x x x x x x
n7=x x x x x x x
n8=x x x x x x x x
n9=x x x x x x x x x

encode1=$(call n$1)
ten-times=$1 $1 $1 $1 $1 $1 $1 $1 $1 $1

encode=$(strip $(and $1,\
  $(call encode1,$(call get-tail-digit,$1)) \
  $(call ten-times,$(call encode,$(call strip-tail-digit,$1))) \
))
decode=$(words $1)

gtx=$(strip $(and \
  $(call bool,$(patsubst %$(call join-with,$2),%,$(call join-with,$1))), \
  $(call eq,$(call join-with,$2),$(patsubst %$(call join-with,$1),%,$(call join-with,$2)))) \
)
gtp=$(call gtx,$(call encode,$1),$(call encode,$2))


gt=$(strip $(if $(call is-negative,$1), \
                $(if $(call is-negative,$2), \
                     $(call gtp,$(call negative,$2),$(call negative,$1)),), \
                $(if $(call is-negative,$2), \
                     t, \
                     $(call gtp,$1,$2))))

ge=$(or $(call eq,$1,$2),$(call gt,$1,$2))
lt=$(call not,$(call ge,$1,$2))
le=$(call not,$(call gt,$1,$2))

incrp=$(call decode,$(call encode,$1) x)
decrp=$(call decode,$(wordlist 2,$1,$(call encode,$1)))

incr=$(strip $(if $(call lt,$1,0), \
                  $(call negative,$(call decrp,$(call negative,$1))), \
                  $(call incrp,$1)))
decr=$(strip $(if $(call le,$1,0), \
                  $(call negative,$(call incrp,$(call negative,$1))), \
                  $(call decrp,$1)))

addp=$(call decode,$(call encode,$1) $(call encode,$2))
subp=$(or $(and $(call ne,$2,0),$(call subp,$(call decr,$1),$(call decr,$2))),$1)

add=$(strip $(if $(call is-negative,$1), \
                 $(call sub,$2,$(call negative,$1)), \
                 $(if $(call is-negative,$2), \
                      $(call sub,$1,$(call negative,$2)), \
                      $(call addp,$1,$2))))

sub=$(strip $(if $(call is-negative,$1), \
                 $(call negative,$(call add,$(call negative,$1),$2)), \
                 $(if $(call is-negative,$2), \
                      $(call add,$1,$(call negative,$2)), \
                      $(call subp,$1,$2))))

mulp=$(strip $(or $(and $(call eq,$2,0),0),\
                  $(and $(call eq,$2,1),$1), \
                  $(call add,$(call mulp,$1,$(call decr,$2)),$1)))

mul=$(strip $(if $(call is-negative,$1), \
                 $(call negative,$(call mul,$(call negative,$1),$2)), \
                 $(if $(call is-negative,$2), \
                      $(call negative,$(call mul,$1,$(call negative,$2))), \
                      $(call mulp,$1,$2))))

divp=$(strip $(or $(and $(call ge,$1,$2), \
                        $(call divp,$(call sub,$1,$2),$2,$(call incr,$3))), \
                  $3))

div=$(strip $(if $(call eq,$2,0), \
                 DIV0, \
                 $(if $(call is-negative,$1), \
                      $(call negative,$(call div,$(call negative,$1),$2)), \
                      $(if $(call is-negative,$2), \
                           $(call negative,$(call div,$1,$(call negative,$2))), \
                           $(call divp,$1,$2,0)))))
