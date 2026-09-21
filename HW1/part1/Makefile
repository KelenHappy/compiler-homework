EXOS = ex11 ex12 ex13 ex14 ex15

all: $(EXOS)
	@for e in $(EXOS); do echo "=== $$e ==="; ./$$e; done

%: %.s
	gcc -g -no-pie $< -o $@

clean:
	rm -f $(EXOS)

.PHONY: all clean
