# License: MIT

test-strings:
	@echo -n '$@ '

	@$(call test1,split-chars,quickbrownfox,q u i c k b r o w n f o x)
	@$(call test1,strlen,quickbrownfox,13)
	@$(call test3,substr,quickbrownfox,1,5,quick)
	@$(call test3,substr,quickbrownfox,3,5,ick)

	@$(call test2,starts-with,quickbrownfox,q,t)
	@$(call test2,starts-with,quickbrownfox,u,)
	@$(call test2,starts-with,quickbrownfox,quick,t)
	@$(call test2,starts-with,quickbrownfox,qq,)
	@$(call test2,starts-with,quickbrownfox,a q b,t)
	@$(call test2,starts-with,quickbrownfox,$(alphabet-chars),t)
	@$(call test2,starts-with,quickbrownfox,$(number-chars),)
	@$(call test2,starts-with,123,12,t)
	@$(call test2,starts-with,123,13,)
	@$(call test2,starts-with,123,$(alphabet-chars),)
	@$(call test2,starts-with,123,$(number-chars),t)

	@$(call test2,ends-with,quickbrownfox,x,t)
	@$(call test2,ends-with,quickbrownfox,o,)
	@$(call test2,ends-with,quickbrownfox,fox,t)
	@$(call test2,ends-with,quickbrownfox,gox,)
	@$(call test2,ends-with,quickbrownfox,$(alphabet-chars),t)
	@$(call test2,ends-with,quickbrownfox,$(number-chars),)
	@$(call test2,ends-with,123,23,t)
	@$(call test2,ends-with,123,33,)
	@$(call test2,ends-with,123,$(alphabet-chars),)
	@$(call test2,ends-with,123,$(number-chars),t)
	@$(call test2,ends-with,123$(rbracket),$(rbracket),t)

	@echo ' ok'
