# License: MIT

# $1: code
# $2: expected result
expect-ok=r=$$($(MAKE) --no-print-directory $1 2>&1); \
if test $$? -ne 0; then \
  echo "Code $1 is expected to success but got error below:"; \
  echo "$$r" | sed 's/^/  > /'; \
  echo; \
  false; \
elif test "$$r" = '$2'; then \
  echo -n .; \
else \
  echo "Code $1 is expected to return '"'$2'"' but got below:"; \
  echo "$$r" | sed 's/^/  > /'; \
  echo; \
  false; \
fi

# $1: code
# $2: expected error message
expect-error=r=$$($(MAKE) --no-print-directory $1 2>&1); \
if test $$? -eq 0; then \
  echo "Code $1 must be error but succeed and got result below:"; \
  echo "$$r" | sed 's/^/  > /'; \
  echo; \
  false; \
elif echo "$$r" | grep '$2' >/dev/null; then \
  echo -n .; \
else \
  echo "Code $1 must be error with message '"'$2'"' but got error below:"; \
  echo "$$r" | sed 's/^/  > /'; \
  echo; \
  false; \
fi

l=(
r=)

test-interpreter2:
	@echo -n '$@ '

	@$(call expect-ok,'(add 1 2 3)',6)
	@$(call expect-ok,'(add 1 (mul 2 3) 4)',11)
	@$(call expect-ok,'(sub 2 3 4)',-5) # left fold
	@$(call expect-ok,'(subr 2 3 4)',3) # right fold
	@$(call expect-ok,'(div 8 4 2)',1) # left fold
	@$(call expect-ok,'(divr 8 4 2)',4) # right fold
	@$(call expect-error,'(add 1)',not enough arguments)
	@$(call expect-error,'(add a b)',undefined variable - "a")
	@$(call expect-error,'(let)',parse-let: first argument must be argument list)
	@$(call expect-error,'(let (a b))',parse-let-add-vars: name-value item must be list)
	@$(call expect-error,'(let (()))',parse-let-add-var: name or value or both are missing)
	@$(call expect-error,'(let ((a)))',parse-let-add-var: name or value or both are missing)
	@$(call expect-ok,'(let ((a 1)))',)
	@$(call expect-error,'(let ((a 1) (a 2)))',multiple variable definition in the same scope and same name)
	@$(call expect-ok,'(let ((a 1 2)) a)',1)
	@$(call expect-ok,'(let ((a (add 1 2))) a)',3)
	@$(call expect-ok,'(let ((a (add 1 2)) (b (add 3 4))) (add a b))',10)
	@$(call expect-ok,'(let ((a (add 1 2)) (b (add 3 4))) a b)',7)
	@$(call expect-error,'(lambda)',parse-lambda: first argument must be argument list)
	@$(call expect-error,'(call)',call: first argument must be lambda)
	@$(call expect-error,'(call 1)',call: first argument must be lambda)
	@$(call expect-ok,'(call (lambda ()))',)
	@$(call expect-error,'(call (lambda (a)))',not enough arguments)
	@$(call expect-ok,'(call (lambda (a)) 1)',)
	@$(call expect-ok,'(call (lambda (a) a) 1)',1)
	@$(call expect-error,'(call (lambda (f) (let ((a 10)) (call f))) (lambda () (print a)))',undefined variable - "a") # static scoping test
	@$(call expect-ok,'(let ((a 1)) (call (lambda (f) (let ((a 2)) (call f))) (lambda () (print a))) )',1) # static scoping test
	@$(call expect-ok,'$(shell cat fib.nl | sed "s/^ \+/ /" | tr -d "\n")',$llist 0 1 1 2 3 5 8 13 21 34$r)

	@echo ' ok'
