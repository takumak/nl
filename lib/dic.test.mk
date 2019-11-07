# License: MIT

test-dic:
	@echo -n '$@ '

	@$(call test2,dic-has-key,test,foo,)
	@$(call test1,dic-keys,test,)
	@$(call test2,dic-get,test,foo,)
	@$(call test3,dic-get,test,foo,bar,bar)
	@$(call test3,dic-set,test,foo,baz,baz)
	@$(call test2,dic-has-key,test,foo,t)
	@$(call test2,dic-get,test,foo,baz)
	@$(call test3,dic-get,test,foo,bar,baz)
	@$(call test1,dic-keys,test,foo)

	@echo ' ok'
