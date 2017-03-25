DIRS=util,x86

main.native: simulator.ml
	ocamlbuild -Is $(DIRS) -lib nums main.native

main.byte: simulator.ml
	ocamlbuild -Is $(DIRS) -lib nums main.byte

all: main.native

clean:
	ocamlbuild -clean
