
dist/sticky-kit.min.js: dist/sticky-kit.js
	closure --language_in=ECMASCRIPT5 $< > $@

dist/sticky-kit.js: sticky-kit.coffee
	coffee -c $<


copy:
	cp jquery.sticky-kit.js site/www/src/
	cp jquery.sticky-kit.min.js site/www/src/
