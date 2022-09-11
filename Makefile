prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	cp ".build/release/binario" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/binario"

clean:
	rm -rf .build

.PHONY: build install uninstall clean