# License: MIT

test-interpreter: test-interpreter-stack

test-interpreter-stack:
	@$(call test0,var-reset)
	@$(call test1,var-exists,null,t)
	@$(call test1,var-get,null,null)

	@$(call test1,var-exists,foo,)
	@$(call test2,var-set,foo,1,1)
	@$(call test1,var-exists,foo,t)
	@$(call test1,var-get,foo,1)

	@$(call test0,var-push)

	@$(call test1,var-exists,foo,t)
	@$(call test1,var-get,foo,1)
	@$(call test1,var-exists,bar,)
	@$(call test2,var-set,bar,2,2)
	@$(call test1,var-exists,bar,t)
	@$(call test1,var-get,bar,2)

	@$(call test0,var-pop)

	@$(call test1,var-exists,foo,t)
	@$(call test1,var-get,foo,1)
	@$(call test1,var-exists,bar,)

	@$(call test0,var-reset)

	@$(call test1,var-exists,foo,)
	@$(call test1,var-exists,bar,)
	@$(call test1,var-exists,null,t)

	@echo; echo $@ ok
