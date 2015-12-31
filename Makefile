FLSC=flsc
FLSCT=flsc -E require:describe:it

all:
	$(FLSC) -i src.fls > topaz.js

runtest:all
	$(FLSCT) -i test.fls > test.js
	mocha test.js
