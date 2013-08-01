
jquery.sticky-kit.min.js: jquery.sticky-kit.js
	closure --language_in=ECMASCRIPT5 $< > $@

jquery.sticky-kit.js: jquery.sticky-kit.coffee
	coffee -c $<


copy:
	cp jquery.sticky-kit.js site/www/src/
	cp jquery.sticky-kit.min.js site/www/src/
