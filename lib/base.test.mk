# License: MIT

test-base:
	@echo -n '$@ '

	$(call test1,bool,x,t)
	$(call test1,bool,,)
	$(call test1,not,x,)
	$(call test1,not,,t)

	$(call test2,eq,,,t)
	$(call test2,eq,x,x,t)
	$(call test2,eq,x,xx,)
	$(call test2,eq,xx,x,)
	$(call test2,eq,x,,)
	$(call test2,eq,,x,)

	$(call test2,ne,,,)
	$(call test2,ne,x,x,)
	$(call test2,ne,x,xx,t)
	$(call test2,ne,xx,x,t)
	$(call test2,ne,x,,t)
	$(call test2,ne,,x,t)

	$(call test2,tail-is,123,3,t)

	@echo ' ok'
