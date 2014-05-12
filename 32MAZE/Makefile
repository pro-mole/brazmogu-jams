#A simple Makefile to create our package

EXECNAME=MAZE
VERSION=0.1
PACKNAME=$(EXECNAME)-$(VERSION).love

all: $(PACKNAME)

$(PACKNAME): *.lua
	zip -9 -q -r $(PACKNAME) *.lua
	
run: all
	#open -n -a love ./
	love ./

clean:
	rm -f *.love
	rm -rf release
