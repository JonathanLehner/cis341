DIRS=util,x86

main.native:
	ocamlbuild -Is $(DIRS) -lib nums main.native

main.byte:
	ocamlbuild -Is $(DIRS) -lib nums main.byte

all: main.native

clean:
	ocamlbuild -clean
