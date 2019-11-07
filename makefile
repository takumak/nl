include interpreter2.mk

run2=$(if $(call ne,$1,null),$(call func-print,$1))
run=$(call run2,$(call exec-one,$(call parse,$@)))

%::
	@# $(call run,$@)

test:
	@$(MAKE) --no-print-directory -f test.mk
