FLSC=flsc
FLSCT=flsc -E require:describe:it

all:
	$(FLSC) -i src.fls -p topaz > topaz.js

runtest:all
	$(FLSCT) -i test.fls > test.js
	mocha test.js
