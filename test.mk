test: test-base test-arithmetic test-list test-dic test-strings test-interpreter

include lib/base.mk
include lib/arithmetic.mk
include lib/list.mk
include lib/dic.mk
include lib/strings.mk

include lib/test.mk

include lib/base.test.mk
include lib/arithmetic.test.mk
include lib/list.test.mk
include lib/dic.test.mk
include lib/strings.test.mk

test-interpreter:
	@$(MAKE) --no-print-directory -f interpreter2.test.mk
