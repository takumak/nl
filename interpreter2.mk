# nantoka-language interpreter no youna mono
#
# License: MIT

include lib/base.mk
include lib/arithmetic.mk
include lib/list.mk
include lib/dic.mk
include lib/strings.mk

ifdef PRINT_TIME
# $1: msg
print=$(info $(shell date +%H:%M:%S.%N): $1)
else
print=$(info $1)
endif

ifdef DEBUG_LEVEL
# $1: level
# $2: msg
debug=$(if $(call le,$1,$(DEBUG_LEVEL)),$(call print,$2))
else
debug=
endif


#### immediates

# $1: word1 (@ or immediate)
# $2: word3 (type name if $1 == @)
get-type2=$(if $(call eq,$1,@),$2,$(if $(call eq,$1,null),null,number))

# $1: words
get-type=$(and $(or $1,$(error get-type: argument(s) required))\
,)$(call get-type2,$(word 1,$1),$(word 3,$1))

# $1: given type name
# $2: required type name
# $3: func name
assert-type2=$(and $(call ne,$1,$2),\
$(error $3: type mismatch - given="$1" required="$2"),)

# $1: words
# $2: required type name
# $3: func name
assert-type=$(call assert-type2,$(call get-type,$1),$2,$3)

## string

string-cnt=0
# returns: string id
add-string=$(string-cnt)$(eval string-$(string-cnt):=$1)$(eval string-cnt=$(call incr,$(string-cnt)))
# $1: string id
get-string=$(value string-$1)

## list

list-cnt=0

# $1: items
# returns: list id
add-list=$(list-cnt)$(and \
$(eval list-$(list-cnt)-size:=0)\
$(call list-append-items,$(list-cnt),$1)\
$(eval list-cnt=$(call incr,$(list-cnt)))\
,)

# $1: list id
list-size=$(value list-$1-size)

# $1: list id
# $2: idx
list-nth=$(value list-$1-$2)

# $1: list id
list-last=$(value list-$1-$(value list-$1-size))

# $1: list id
# $2: cur idx
list-all2=$(strip $(and $(call le,$2,$(value list-$1-size)),\
$(value list-$1-$2) $(call list-all2,$1,$(call incr,$2))))

# $1: list id
list-all=$(call list-all2,$1,1)

# $1: list id
# $2: any value
list-append=$(and \
$(eval list-$1-size:=$(call incr,$(value list-$1-size)))\
$(eval list-$1-$(value list-$1-size):=$2)\
,)

# $1: list id
# $2: items
list-append-items=$(and $2,\
$(call debug,2,list-append-items: list-id=$1 items="$2")\
$(call list-append,$1,$(call extract-one-value,$2,1))\
$(call list-append-items,$1,$(call slice,$2,$(call next-value-idx,$2,1)))\
,)

## let

let-cnt=0

# $1: var ids
# $2: var values
# $3: body
# returns: let id
add-let=$(call debug,2,add-let: return let-id=$(let-cnt))$(let-cnt)$(and \
$(eval let-cnt=$(call incr,$(let-cnt)))\
,)

# $1: let id
get-let-var-ids=$(value let-$1-var-ids)

# $1: let id
get-let-var-values=$(value let-$1-var-values)

# $1: let id
get-let-body=$(value let-$1-body)

# $1: let id
# $2: var id
# $3: var value
let-add-var=$(call debug,2,let-add-var: let-id=$1 var-id="$2" value="$3")$(and \
$(eval let-$1-var-ids:=$(let-$1-var-ids) $2)\
$(eval let-$1-var-values:=$(let-$1-var-values) $3)\
,)

# $1: let id
# $2: body
let-set-body=$(call debug,2,let-set-body: let-id=$1 body="$2")$(and \
$(eval let-$1-body:=$2)\
,)

## lambda

lambda-cnt=0
# $1: args
# $2: body
# returns: lambda id
add-lambda=$(call debug,2,add-lambda: args="$1" body="$2")$(lambda-cnt)$(and \
$(eval lambda-$(lambda-cnt)-args:=$1)\
$(eval lambda-$(lambda-cnt)-body:=$2)\
$(eval lambda-cnt=$(call incr,$(lambda-cnt)))\
,)
# $1: lambda id
get-lambda-args=$(value lambda-$1-args)
# $1: lambda id
get-lambda-body=$(value lambda-$1-body)

## args

args-cnt=0
# returns: args id
add-args=$(args-cnt)$(eval args-cnt=$(call incr,$(args-cnt)))
# $1: args id
get-args=$(value args-$1)
# $1: args id
# $2: arg
args-push=$(call debug,2,args-push: args-id=$1 arg="$2")$(eval args-$1:=$(args-$1) $2)


#### variables stack

var-id-seed:=0
var-stack-depth:=0

var-pop=$(and \
$(call debug,2,var-pop)\
$(and $(call le,$(var-stack-depth),0),$(error var-stack: attempted over pop))\
$(eval var-stack-depth:=$(call decr,$(var-stack-depth)))\
,)

var-push=$(and \
$(call debug,2,var-push)\
$(eval var-stack-depth:=$(call incr,$(var-stack-depth)))\
$(call dic-clear,var-stack-$(var-stack-depth))\
,)

# $1: var name
# returns: var id
var-register=$(call debug,2,var-register: name="$1")$(and \
$(call dic-has-key,var-stack-$(var-stack-depth),$1),\
$(error multiple variable definition in the same scope and same name)\
,)$(var-id-seed)$(and $(call dic-set,var-stack-$(var-stack-depth),$1,$(var-id-seed))\
$(eval var-id-seed:=$(call incr,$(var-id-seed))),)

# $1: var name
# $2: cur stack idx
# returns: stack idx
var-lookup2=$(and $(call lt,$2,0),$(error undefined variable - "$1"))$(and \
$(call debug,2,var-lookup2: name="$1" stack-idx=$2)\
,)$(or $(and $(call dic-has-key,var-stack-$2,$1),$2),$(strip \
)$(call var-lookup2,$1,$(call decr,$2)))

# $1: var name
# $2: var id
var-lookup=$(call dic-get,var-stack-$(call var-lookup2,$1,$(var-stack-depth)),$1)

var-reset=$(call debug,2,var-reset)$(and \
$(eval var-stack-depth:=0)\
$(call dic-clear,var-stack-0)\
,)

# $1: var id
# $2: value
var-set=$(call debug,2,var-set: var-id=$1 value="$2")$(eval var-$1:=$2)

# $1: var id
var-get=$(value var-$1)


#### export functions

# $1: words
pfunc-progn3=$(and $1,$(or $(strip \
)$(call pfunc-progn3,$(call slice,$1,$(call next-value-idx,$1,1))),$1))
pfunc-progn2=$(call debug,2,pfunc-progn2: words="$1")$(or $(call pfunc-progn3,$1),null)
func-progn=$(call pfunc-progn2,$(call exec2,$1))

## io functions

pfunc-print-get-null=$1
pfunc-print-get-number=$1
pfunc-print-get-string=$(call get-string,$(word 4,$1))
pfunc-print-get-list=(list $(call pfunc-print-eval,$(call list-all,$(word 4,$1))))
pfunc-print-get-lambda=(lambda ($(call get-lambda-args,$(word 4,$1))) $(call get-lambda-body,$(word 4,$1)))

# $1: words
# $2: type name of first word
pfunc-print-eval2=$(and \
$(call eq,$(origin pfunc-print-get-$2),undefined),\
$(error print: unsupported type - "$2")\
,)$(call pfunc-print-get-$2,$1)

# $1: words
pfunc-print-eval=$(strip $(and $1,\
$(call pfunc-print-eval2,$(call extract-one-value,$1,1),$(call get-type,$1))\
$(call pfunc-print-eval,$(call slice,$1,$(call next-value-idx,$1,1)))\
))

# $1: words
func-print=$(call print,$(call pfunc-print-eval,$(call exec2,$1)))

## arithmetic functions

# $1: func name
# $2: args
left-fold=$(or\
$(and $(call lt,$(words $2),2),$(or $(error $1: not enough arguments),t)),\
$(and $(call eq,$(words $2),2),$(call $1,$(word 1,$2),$(word 2,$2))),\
$(call $1,$(call left-fold,$1,$(call chop,$2)),$(call last,$2)))

# $1: func name
# $2: args
right-fold=$(or\
$(and $(call lt,$(words $2),2),$(or $(error $1: not enough arguments),t)),\
$(and $(call eq,$(words $2),2),$(call $1,$(word 1,$2),$(word 2,$2))),\
$(call $1,$(word 1,$2),$(call right-fold,$1,$(call rest,$2))))

func-add=$(call left-fold,add,$(call exec2,$1))
func-sub=$(call left-fold,sub,$(call exec2,$1))
func-subr=$(call right-fold,sub,$(call exec2,$1))
func-mul=$(call left-fold,mul,$(call exec2,$1))
func-div=$(call left-fold,div,$(call exec2,$1))
func-divr=$(call right-fold,div,$(call exec2,$1))

## bool functions

# $1: a word
chk-bool=$(call not,$(filter 0 null,$(call exec-one,$1)))

# $1: t if cond == true
# $2: true statement
# $3: false statement
pfunc-if4=$(and \
$(call debug,2,if: cond=$(if $1,true,false) then="$2" else="$3")\
,)$(and $1,$(call exec2,$2))$(and $(call not,$1),$(call exec2,$3))

# $1: words
# $2: idx of true statement
# $3: idx of false statement
pfunc-if3=$(call pfunc-if4,$(strip \
)$(call chk-bool,$(call exec2,$(wordlist 1,$(call decr,$2),$1))),$(strip \
)$(wordlist $2,$(call decr,$3),$1),$(strip \
)$(call extract-one-value,$1,$3))

# $1: words
# $2: idx of true statement
pfunc-if2=$(call pfunc-if3,$1,$2,$(call next-value-idx,$1,$2))

# $1: words
func-if=$(call pfunc-if2,$1,$(call next-value-idx,$1,1))

func-not=$(if $(call chk-bool,$(call exec-one,$1)),0,1)

pfunc-eq2=$(if $(and $(call ne,$(word 1,$1),@),$(call eq,$(word 1,$1),$(word 2,$1))),1,0)
func-eq=$(call pfunc-eq2,$(call exec2,$1))

func-ne=$(if $(call eq,$(call func-eq,$1),1),0,1)

## list functions

func-list=@ 4 list $(call add-list,$(call exec2,$1))

# $1: list
# $2: any value
pfunc-append2=$(and \
$(call assert-type,$1,list,pfunc-append2)\
,)$1$(call list-append,$(word 4,$1),$2)

# $1: words
func-append=$(call pfunc-append2,$(strip \
)$(call exec-one,$1),$(call exec-one,$(call next-value,$1)))

# $1: list
# $2: number
pfunc-nth2=$(and \
$(call assert-type,$1,list,pfunc-nth2)\
$(call assert-type,$2,number,pfunc-nth2)\
,)$(call list-nth,$(word 4,$1),$2)

# $1: words
func-nth=$(call pfunc-nth2,$(call exec-one,$1),$(call exec2,$(call next-value,$1)))

# $1: list
pfunc-last2=$(and \
$(call assert-type,$1,list,pfunc-last2)\
,)$(call list-last,$(word 4,$1))

# $1: words
func-last=$(call pfunc-last2,$(call exec-one,$1))

# $1: words
pfunc-size2=$(and \
$(call assert-type,$1,list,pfunc-size2)\
,)$(call list-size,$(word 4,$1))

# $1: words
func-size=$(call pfunc-size2,$(call exec-one,$1))

## call

# $1: arg var ids
# $2: arg values
# $3: first value size
pfunc-call-assign2=$(and \
$(call debug,2,pfunc-call-assign2: arg-var-ids="$1" arg-values="$2" first-value-size=$3)\
$(and $1,$(call not,$2),$(error not enough arguments))\
$(and $(call not,$1),$2,$(error too many arguments))\
,)$(and $1,\
$(call var-set,$(word 1,$1),$(call exec2,$(wordlist 1,$3,$2)))\
$(call pfunc-call-assign,$(call rest,$1),$(call slice,$2,$(call incr,$3)))\
,)

# $1: arg var ids
# $2: arg values
pfunc-call-assign=$(call pfunc-call-assign2,$1,$2,$(strip \
)$(if $(call eq,$(word 1,$2),@),$(word 2,$2),1))

# $1: lambda id
# $2: args
# $3: t if args is not empty
pfunc-call3=$(call debug,2,pfunc-call3: lambda-id=$1 args="$2")$(strip \
)$(and $3,$(call var-push)$(call pfunc-call-assign,$(call get-lambda-args,$1),$2),)$(strip \
)$(call pfunc-progn2,$(call exec2,$(call get-lambda-body,$1)))$(strip \
)$(and $3,$(call var-pop),)

# $1: @ 4 lambda <lambda id>
# $2: args ...
pfunc-call2=$(call debug,2,pfunc-call2: words="$1")$(and $(or\
$(call ne,$(word 1,$1),@),\
$(call ne,$(word 2,$1),4),\
$(call ne,$(word 3,$1),lambda)),\
$(error call: first argument must be lambda)\
,)$(call pfunc-call3,$(word 4,$1),$2,$(call bool,$(call get-lambda-args,$(word 4,$1))))

# $1: result
pfunc-call-log=$(call debug,1,call: result="$1")$1

func-call=$(call pfunc-call-log,$(call pfunc-call2,$(strip \
)$(call exec-one,$1),$(call slice,$1,$(call next-value-idx,$1,1))))


#### parse

# $1: a word
tokenize-word=$(or \
$(and $(call starts-with,$1,$(lbracket)),$(lbracket) $(call tokenize-word,$(patsubst $(lbracket)%,%,$1))),\
$(and $(call ends-with,$1,$(rbracket)),$(call tokenize-word,$(patsubst %$(rbracket),%,$1)) $(rbracket)),\
$1)

# $1: words
tokenize=\
$(and $(call ne,$(words $1),0),$(call tokenize-word,$(word 1,$1)))\
$(and $(call gt,$(words $1),1),$(call tokenize,$(call rest,$1)))

# $1: all words
# $2: current index
find-close=$(and \
$(call debug,3,find-close: words="$1" curr=$2)\
$(and $(call gt,$2,$(words $1)),$(error failed to find close bracket))\
,)$(strip $(or \
$(and $(call eq,$(word $2,$1),$(rbracket)),$2),\
$(and $(call eq,$(word $2,$1),$(lbracket)),\
      $(call find-close,$1,$(call incr,$(call find-close,$1,$(call incr,$2))))),\
$(call find-close,$1,$(call incr,$2))))

## call

# $1: args id
# $2: arg1 arg2 ...
parse-call-arg=$(call debug,2,parse-call-arg: args-id=$1 args="$2")$(call args-push,$1,$(call parse2,$2))

# $1: args id
# $2: arg1 arg2 ...
parse-call-args2=$1$(call parse-call-arg,$1,$2)

# $1: arg1 arg2 ...
parse-call-args=$(call debug,2,parse-call-args: args="$1")$(call parse-call-args2,$(call add-args),$1)

# $1: function name
# $2: arg list
parse-call2=@ $(call add,$(words $2),4) call $1 $2

# $1: words
parse-call=$(call debug,2,parse-call: words="$1")$(strip \
)$(call parse-call2,$(word 1,$1),$(call parse-call-args,$(call rest,$1)))

## let

# $1: name value
# $2: let id
parse-let-add-var=$(and \
$(call lt,$(words $1),2),$(error parse-let-add-var: name or value or both are missing)\
,)$(call let-add-var,$2,$(call var-register,$(word 1,$1)),$(strip \
)$(call extract-one-value,$(call parse2,$(call slice,$1,2)),1))

# $1: (name1 value1) (name2 value2) ...
# $2: end idx of first brackets
# $3: let id
parse-let-add-vars2=$(strip \
)$(call parse-let-add-var,$(wordlist 2,$(call decr,$2),$1),$3)$(strip \
)$(and $(call gt,$(words $1),$2),$(strip \
      )$(call parse-let-add-vars,$(call slice,$1,$(call incr,$2)),$3))

# $1: (name1 value1) (name2 value2) ...
# $2: let id
parse-let-add-vars=$(and \
$(call ne,$(word 1,$1),$(lbracket)),\
$(error parse-let-add-vars: name-value item must be list)\
,)$(call parse-let-add-vars2,$1,$(call find-close,$1,2),$2)

# $1: ((name1 value1) (name2 value2) ...) body...
# $2: end idx of variables list
# $3: let id
parse-let3=@ 4 let $3$(and \
$(call parse-let-add-vars,$(wordlist 2,$(call decr,$2),$1),$3)\
$(call let-set-body,$3,$(call parse2,$(call slice,$1,$(call incr,$2))))\
,)

# $1: ((name1 value1) (name2 value2) ...) body...
# $2: end idx of variables list
parse-let2=$(call parse-let3,$1,$2,$(call add-let))

# $1: ((name1 value1) (name2 value2) ...) body...
parse-let=$(call debug,2,parse-let: words="$1")$(call var-push)$(and \
$(call ne,$(word 1,$1),$(lbracket)),\
$(error parse-let: first argument must be argument list)\
,)$(call parse-let2,$1,$(call find-close,$1,2))$(call var-pop)

## lambda

# $1: arg1 arg2 ...
parse-lambda-register-args=$(strip $(and $1,$(call var-register,$(word 1,$1)) \
$(call parse-lambda-register-args,$(call slice,$1,2))))

# $1: arg1 arg2 ... (parsed; var ids)
# $2: body... (not parsed)
parse-lambda3=$(and \
$(call debug,2,parse-lambda3: args="$1" body="$2")\
,)$(call add-lambda,$1,$(call parse2,$2))

# $1: (arg1 arg2 ...) body...
# $2: end idx of argument list
parse-lambda2=@ 4 lambda $(call parse-lambda3,$(strip \
)$(call parse-lambda-register-args,$(wordlist 2,$(call decr,$2),$1)),$(strip \
)$(call slice,$1,$(call incr,$2)))

# $1: (arg1 arg2 ...) body...
parse-lambda=$(call debug,2,parse-lambda: words="$1")$(call var-push)$(and \
$(call ne,$(word 1,$1),$(lbracket)),\
$(error parse-lambda: first argument must be argument list)\
,)$(call parse-lambda2,$1,$(call find-close,$1,2))$(call var-pop)

## parse

# $1: words
# $2: end idx
parse-bracket=$(and \
$(call debug,2,parse-bracket: words="$1" end-idx=$2)\
,)$(strip \
$(if $(call eq,$(word 1,$1),lambda),$(strip \
    )$(call parse-lambda,$(wordlist 2,$(call decr,$2),$1)),$(strip \
    )$(if $(call eq,$(word 1,$1),let),$(strip \
         )$(call parse-let,$(wordlist 2,$(call decr,$2),$1)),$(strip \
         )$(call parse-call,$(wordlist 1,$(call decr,$2),$1))))$(strip \
    ) $(if $(call lt,$2,$(words $1)),$(call parse2,$(call slice,$1,$(call incr,$2)))))

# $1: words
# $2: first token
parse3=$(strip $(call debug,2,parse3: words="$1")$(strip \
)$(if $(call eq,$2,$(lbracket)),$(strip \
     )$(call parse-bracket,$(call rest,$1),$(call decr,$(call find-close,$1,2))),$(strip \
     )$(if $(call starts-with,$2,$(number-chars)),$2,$(strip \
          )$(if $(call starts-with,$2,$(and ",")),@ 4 string $(call add-string,$2),$(strip \
               )@ 4 var $(call var-lookup,$(word 1,$1))))$(strip \
     ) $(if $(call gt,$(words $1),1),$(call parse2,$(call rest,$1)))))

# $1: words
parse2=$(and $1,$(call parse3,$1,$(word 1,$1),$2,$3))

# $1: words
parse=$(call var-reset)$(call parse2,$(call tokenize,$1))


#### exec

# $1: words
# $2: idx of words to check
next-value-idx=$(strip \
$(if $(call eq,$(word $2,$1),@),\
     $(call add,$2,$(word $(call incr,$2),$1)),\
     $(call incr,$2)))

# $1: words
# $2: idx of words to check (optional)
next-value=$(call extract-one-value,$1,$(call next-value-idx,$1,$(or $2,1)))

# $1: words
# $2: idx
nth-value=$(and \
$(and $(or $(call lt,$2,1),$(call not,$1)),$(error nth-value: index out of range))\
,)$(and $(call eq,$2,1),$(call extract-one-value,$1,1))$(strip \
)$(and $(call ne,$2,1),$(call nth-value,$(call slice,$1,$(call next-value-idx,$1,1)),$(call decr,$2)))

# $1: words
# $2: idx of words to extract
extract-one-value=$(if $(call eq,$(word $2,$1),@),$(strip \
)$(wordlist $2,$(call decr,$(call add,$2,$(word $(call incr,$2),$1))),$1),$(strip \
)$(word $2,$1))

# $1: words
# $2: idx of words to exec (optional)
exec-one=$(call exec2,$(call extract-one-value,$1,$(or $2,1)))

# $1: var id
exec-var=$(call var-get,$1)

# $1: function name
# $2: args id
exec-call2=$(call debug,2,exec-call2: func="$1" args-id="$2")$(and \
$(call eq,$(origin func-$1),undefined),\
$(error undefined function - "$1")\
,)$(or $(call func-$1,$(call get-args,$2)),null)
# $1: <function name> <args id>
exec-call=$(call exec-call2,$(word 1,$1),$(word 2,$1))

# $1: id1 id2 ...
# $2: value1 value2 ...
exec-let-assign=$(and $1,\
$(call debug,2,exec-let-assign: ids="$1" values="$2")\
$(call var-set,$(word 1,$1),$(call exec-one,$2))\
$(call exec-let-assign,$(call slice,$1,2),$(call slice,$2,$(call next-value-idx,$2,1)))\
,)
# $1: let id
exec-let=$(call exec-let-assign,$(call get-let-var-ids,$1),$(call get-let-var-values,$1))$(strip \
)$(call pfunc-progn2,$(call exec2,$(call get-let-body,$1)))

# $1: words
# $2: 1st word of $1 (@ or immediate)
# $3: 2nd word of $1 (size if $2 = @)
# $4: 3rd word of $1 (name if $2 = @)
exec3=$(strip $(if $(call eq,$2,@),$(if $(filter string list lambda,$4),\
$(wordlist 1,$3,$1),$(call exec2,$(call exec-$4,$(wordlist 4,$3,$1))))\
$(and $(call gt,$(words $1),$3),$(call exec2,$(call slice,$1,$(call incr,$3)))),\
$(word 1,$1) $(and $(call gt,$(words $1),1),$(call exec2,$(call rest,$1)))))

# $1: words
exec2=$(and \
$(call debug,2,exec2: words="$1")\
,)$(call exec3,$1,$(word 1,$1),$(word 2,$1),$(word 3,$1))

# $1: words
exec=$(call exec2,$1)
