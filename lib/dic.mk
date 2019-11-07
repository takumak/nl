# License: MIT

# requires: base

# $1: dictionary name
# $2: key
dic-has-key=$(call bool,$(filter $2,$(value dic-keys--$1)))

# $1: dictionary name
# $2: key
# $3: value
dic-set=$(if $(call not,$(call dic-has-key,$1,$2)),$(eval dic-keys--$1:=$(value dic-keys--$1) $2))$(eval dic--$1--$2:=$3)$3

# $1: dictionary name
# $2: key
# $3: default value
dic-get=$(if $(call dic-has-key,$1,$2),$(value dic--$1--$2),$3)

# $1: dictionary name
dic-keys=$(value dic-keys--$1)

# $1: dictionary name
dic-clear=$(eval dic-keys--$1:=)
