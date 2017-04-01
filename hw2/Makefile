DIRS=util,x86

main.native: simulator.ml
	ocamlbuild -cflag -bin-annot -Is $(DIRS) -lib nums main.native

main.byte: simulator.ml
	ocamlbuild -cflag -bin-annot -Is $(DIRS) -lib nums main.byte

all: main.native

clean:
	ocamlbuild -clean
