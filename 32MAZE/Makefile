#A simple Makefile to create our package

EXECNAME=MAZE
VERSION=1.0
PACKNAME=$(EXECNAME)-$(VERSION).love

all: $(PACKNAME)

$(PACKNAME): *.lua
	zip -9 -q -r $(PACKNAME) *.lua assets
	
run: all
	#open -n -a love ./
	love ./

clean:
	rm -f *.love
	rm -rf release
