# License: MIT

# requires: base.mk arithmetic.mk list.mk

alphabet-chars:=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
alphabet-chars+=a b c d e f g h i j k l m n o p q r s t u v w x y z
number-chars:=0 1 2 3 4 5 6 7 8 9

all-chars:=$(alphabet-chars) $(number-chars)
all-chars+=$(and `,`) ~ ! @ \# $$ % ^ & * ( ) - _ = +
all-chars+={ } [ ] \ : ; $(and ',') $(and ",") < > , . / ? |

# private function
split-chars2=$(strip $(or $(and $(call ne,$(words $2),0),$(call split-chars2,$(subst $(word 1,$2),$(word 1,$2) ,$1),$(call rest,$2))),$1))

# $1: a word
split-chars=$(call split-chars2,$1,$(all-chars))

# $1: a word
strlen=$(words $(call split-chars,$1))

# $1: a word
# $2: start index (starts from 1; can be negative number)
# $3: end index (inclusive; can be negative number)
substr=$(call join-with,$(call slice,$(call split-chars,$1),$2,$3))

# $1: a word
# $2: check words
starts-with=$(strip $(or \
$(call ne,$1,$(patsubst $(word 1,$2)%,%,$1)), \
$(and $(call gt,$(words $2),1),$(call starts-with,$1,$(call rest,$2)))))

# $1: a word
# $2: check words
ends-with=$(strip $(or \
$(call ne,$1,$(patsubst %$(word 1,$2),%,$1)), \
$(and $(call gt,$(words $2),1),$(call ends-with,$1,$(call rest,$2)))))
