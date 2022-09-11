prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

build-universal:
	swift build -c release --arch arm64 --arch x86_64 --disable-sandbox

install: build
	install -d "$(bindir)"
	install ".build/release/binario" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/binario"

clean:
	rm -rf .build

.PHONY: build install uninstall clean