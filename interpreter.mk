# nantoka-language interpreter no youna mono
#
# License: MIT

include lib/base.mk
include lib/arithmetic.mk
include lib/list.mk
include lib/dic.mk
include lib/strings.mk


# $1: msg
ifdef PRINT_TIME
print=$(info $(shell date +%H:%M:%S.%N): $1)
else
print=$(info $1)
endif

DEBUG_LEVEL=0

# $1: level
# $2: msg
debug=$(if $(call le,$1,$(DEBUG_LEVEL)),$(call print,$2))

var-stack-depth:=0
var-pop=$(and \
$(and $(call le,$(var-stack-depth),0),$(error var-stack: attempted over pop))\
$(eval var-stack-depth:=$(call decr,$(var-stack-depth)))\
,)
var-push=$(and \
$(eval var-stack-depth:=$(call incr,$(var-stack-depth)))\
$(call dic-clear,var-stack-$(var-stack-depth))\
,)

# $1: var name
# $2: cur stack idx
# returns: stack idx
var-search=$(strip $(and $(call ge,$2,0),\
$(call debug,2,var-search name="$1" stack-idx=$2)\
$(or $(and $(call dic-has-key,var-stack-$2,$1),$2),\
$(call var-search,$1,$(call decr,$2)))))

# $1: var name
# $2: var value
var-get-log=$(call debug,2,var-get: name="$1" value="$2")$2

# $1: var name
var-get=$(call var-get-log,$1,$(strip \
)$(call dic-get,var-stack-$(call var-search,$1,$(var-stack-depth)),$1))

# $1: var name
# $2: value
var-set=$(call debug,2,var-set $1=$2)$(call dic-set,var-stack-$(var-stack-depth),$1,$2)

# $1: var name
var-exists=$(call bool,$(call var-search,$1,$(var-stack-depth)))

var-reset=$(call debug,2,var-reset)$(and \
$(eval var-stack-depth:=0)\
$(call dic-clear,var-stack-0)\
$(call var-set,null,null)\
,)



#### export functions

func-names:=

func-names+=progn
progn=$(if $(call ge,$(words $1),1),$(call last,$1))
func-progn=$(call progn,$(call eval-args,$1))

func-names+=print
func-print=$(call print,$(call eval-word2,$1,1))

func-names+=if
chk-bool=$(call not,$(filter null 0,$1))
# $1: args
# $2: run idx
func-if2=$(and $(call le,$2,$(words $1)),$(call eval-word2,$1,$2))
func-if=$(and $(or \
$(and $(call chk-bool,$(call eval-word2,$1,1)),$(strip \
$(call debug,2,if cond=true)\
)$(or $(call func-if2,$1,$(call next-word,$1,1)),t)),$(strip \
$(call debug,2,if cond=false)\
)$(call func-if2,$1,$(call next-word,$1,$(call next-word,$1,1)))),)

func-names+=not
func-not=$(if $(call chk-bool,$(call eval-word2,$1,1)),0,1)

func-names+=eq
func-eq2=$(call debug,2,func-eq2: "$1"=="$2")$(if $(call eq,$1,$2),1,0)
func-eq=$(call func-eq2,$(call eval-word2,$1,1),$(call eval-word2,$1,$(call next-word,$1,1)))

func-names+=let
# name value
let-assign=$(call debug,2,let-assign $(word 1,$1)=$(word 2,$1))\
$(call var-set,$(word 1,$1),$(call eval-word2,$1,2))
# (name1 value1) (name2 value2)
let-assign-all=$(call debug,2,let-assign-all words="$1")$(and \
$(and $(call gt,$(words $1),0),\
$(and $(call ne,$(word 1,$1),$(lbracket)),$(error let: variable list items must be list))\
$(call let-assign,$(wordlist 2,$(call decr,$(call find-close,$1,2)),$1))\
$(call let-assign-all,$(call slice,$1,$(call incr,$(call find-close,$1,2))))\
),)
# $1: args
# $2: end index of first arg
func-let2=$(strip \
$(call let-assign-all,$(wordlist 2,$(call decr,$2),$1))\
)$(call progn,$(call eval-args,$(call slice,$1,$(call incr,$2))))
func-let=$(and $(strip \
$(and $(call ne,$(word 1,$1),$(lbracket)),$(error let: first argument must be a list))\
)$(call func-let2,$1,$(call find-close,$1,2))$(strip \
),)

func-names+=call
# $1: arg name list
# $2: arg value list
func-call-assign=$(call debug,2,call-assign names="$1" values="$2")$(and \
$(and $(call ge,$(words $1),1),$(call ge,$(words $2),1)),\
$(call var-set,$(word 1,$1),$(call eval-word2,$2,1))\
$(call func-call-assign,$(call rest,$1),$(call slice,$2,$(call next-word,$2,1)))\
,)
# $1: (lambda () ...) arg1 arg2 ...
# $2: end idx of argument list
# $3: end idx of lambda
func-call3=$(call debug,2,call3 "$1" arglist-end=$2 lambda-end=$3)$(and \
$(call func-call-assign,$(wordlist 4,$(call decr,$2),$1),$(call slice,$1,$(call incr,$3)))\
,)$(call progn,$(call eval-args,$(wordlist $(call incr,$2),$(call decr,$3),$1)))
func-call2=$(and \
$(or $(and $(call eq,$(word 1,$1),$(lbracket)),$(call eq,$(word 2,$1),lambda)),\
$(error call: first argument must be lambda))\
$(or $(call eq,$(word 3,$1),$(lbracket)),\
$(error call: lambda has no argument list))\
,)$(call func-call3,$1,$(call find-close,$1,4),$(call find-close,$1,2))
func-call=$(call func-call2,$(call eval-args,$1))

# $1: func name
# $2: args
left-fold=$(or\
$(and $(call lt,$(words $2),2),$(or $(error not enough arguments),t)),\
$(and $(call eq,$(words $2),2),$(call $1,$(word 1,$2),$(word 2,$2))),\
$(call $1,$(call left-fold,$1,$(call chop,$2)),$(call last,$2)))

# $1: func name
# $2: args (evaluated)
right-fold=$(or\
$(and $(call lt,$(words $2),2),$(or $(error not enough arguments),t)),\
$(and $(call eq,$(words $2),2),$(call $1,$(word 1,$2),$(word 2,$2))),\
$(call $1,$(word 1,$2),$(call right-fold,$1,$(call rest,$2))))

func-names+=add sub mul div
func-add=$(call left-fold,add,$(call eval-args,$1))
func-sub=$(call left-fold,sub,$(call eval-args,$1))
func-mul=$(call left-fold,mul,$(call eval-args,$1))
func-div=$(call left-fold,div,$(call eval-args,$1))

# $1: func name
# $2: args
# $3: result
call-func-log=$(call debug,1,CALL $1($2) => $3)$3

# $1: first word is function name, rests are arguments
call-func=$(and \
$(or $(filter $(word 1,$1),$(func-names)),$(error undefined function: $(word 1,$1)))\
$(call debug,2,call-func $1)\
$(call var-push)\
,)$(call call-func-log,$(word 1,$1),$(call rest,$1),$(call func-$(word 1,$1),$(call rest,$1)))$(and \
$(call var-pop),)



#### parser


# $1: all words
# $2: current index
find-close=$(call debug,3,find-close words="$1" curr=$2)$(strip $(or \
$(and $(call gt,$2,$(words $1)),$(error failed to find close bracket)),\
$(and $(call eq,$(word $2,$1),$(rbracket)),$2),\
$(and $(call eq,$(word $2,$1),$(lbracket)),\
      $(call find-close,$1,$(call incr,$(call find-close,$1,$(call incr,$2))))),\
$(call find-close,$1,$(call incr,$2))))

# $1: all words
# $2: current index
# returns: index of next word
next-word=$(strip $(if $(call eq,$(word $2,$1),$(lbracket)),\
$(call incr,$(call find-close,$1,$(call incr,$2))),\
$(call incr,$2)))


# $1: all words
# $2: current index
# $3: max index (inclusive)
eval-args2=$(strip $(call debug,2,eval-args2 words="$1" curr=$2 max=$3)\
)$(and $(call le,$2,$3),$(call eval-word2,$1,$2) $(and $(call lt,$2,$3),$(strip \
$(call eval-args2,$1,$(call next-word,$1,$2),$3)\
)))

# $1: all words
# $2: result
eval-args-log=$(call debug,2,eval-args "$1" => "$2")$2

# $1: all words
eval-args=$(call eval-args-log,$1,$(call eval-args2,$1,1,$(words $1)))

# $1: var name
eval-var=$(call debug,2,eval-var word=$1)$(strip \
)$(if $(call starts-with,$1,$(number-chars)),$1,$(strip \
)$(if $(call starts-with,$1,$(and ",")),$(call substr,$1,2,-2),$(strip \
)$(if $(call var-exists,$1),$(call var-get,$1),$(strip \
)$(if $(filter $1,$(func-names)),$1,$(strip \
)$(error undefined variable $1)))))

# $1: all words
# $2: word index
eval-word2=$(call debug,2,eval-word2 words="$1" curr=$2)$(strip \
)$(if $(call eq,$(word $2,$1),$(lbracket)),$(strip \
     )$(if $(call eq,$(word $(call incr,$2),$1),lambda),$(strip \
          )$(wordlist $2,$(call find-close,$1,$(call incr,$2)),$1),$(strip \
          )$(call call-func,$(wordlist $(call incr,$2),$(strip \
                 )$(call decr,$(call find-close,$1,$(call incr,$2))),$1))),$(strip \
     )$(call eval-var,$(word $2,$1)))

# $1: a word
eval-prep-word=$(if \
$(call starts-with,$1,$(lbracket)),$(lbracket) $(call eval-prep-word,$(call substr,$1,2)),$(if \
$(call ends-with,$1,$(rbracket)),$(call eval-prep-word,$(call substr,$1,1,-2)) $(rbracket),$1))

# $1: words
eval-prep=$(call eval-prep-word,$(word 1,$1)) $(and $(call gt,$(words $1),1),$(call eval-prep,$(call rest,$1)))

# $1: words to be evaluated
# $2: argv
exec=$(call var-reset)$(and $(call var-set,argv,$2),)$(call eval-word2,$(call eval-prep,$1),1)
