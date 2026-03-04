PREFIX ?= $(HOME)/.local

install:
	mkdir -p $(PREFIX)/bin
	install -Dm755 src/mojicrypt $(PREFIX)/bin/mojicrypt
	@echo "installed to $(PREFIX)/bin/mojicrypt"

remove:
	rm -f $(PREFIX)/bin/mojicrypt

.PHONY: install remove
