# License: MIT

map-test-func=$(call mul,$1,$1):$2/$(words $3)

test-list:
	@echo -n '$@ '

	@$(call test1,first,1 2 3,1)
	@$(call test1,last,1 2 3,3)
	@$(call test1,rest,1 2 3,2 3)
	@$(call test1,chop,1 2 3,1 2)

	@$(call test3,slice,1 2 3 4 5,1,2,1 2)
	@$(call test3,slice,1 2 3 4 5,2,2,2)
	@$(call test3,slice,1 2 3 4 5,2,0,)
	@$(call test3,slice,1 2 3 4 5,2,-1,2 3 4 5)
	@$(call test3,slice,1 2 3 4 5,2,-2,2 3 4)
	@$(call test3,slice,1 2 3 4 5,1,-4,1 2)
	@$(call test2,slice,1 2 3 4 5,2,2 3 4 5)
	@$(call test2,slice,1 2 3 4 5,-1,5)
	@$(call test2,slice,1 2 3 4 5,-2,4 5)

	@$(call test1,seq,5,1 2 3 4 5)
	@$(call test2,seq,3,5,3 4 5)
	@$(call test2,seq,5,5,5)
	@$(call test2,seq,6,5,)
	@$(call test2,seq,-1,1,-1 0 1)
	@$(call test2,map,$(call seq,4),map-test-func,1:1/4 4:2/4 9:3/4 16:4/4)

	@echo ' ok'
