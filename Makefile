BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/static

serve:
	cd $(OUTPUTDIR); python2 -m SimpleHTTPServer 5555

github: 
	echo "ascii-breakout.com" > $(OUTPUTDIR)/CNAME
	java -jar ~/bin/compiler.jar --js_output_file=static/js/ascii-breakout.min.js static/js/ascii-breakout.js
	sed -i -e s/ascii-breakout.js/ascii-breakout.min.js/ static/index.html
	ghp-import -p static/
	sed -i -e s/ascii-breakout.min.js/ascii-breakout.js/ static/index.html

wcoffee:
	coffee -o static/js -cw coffee/
wsass:
	sass --watch sass:static/css
