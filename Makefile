BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/static

serve:
	cd $(OUTPUTDIR); python2 -m SimpleHTTPServer 5555

github: 
	echo "ascii-breakout.com" > $(OUTPUTDIR)/CNAME
	java -jar ~/bin/compiler.jar --js_output_file=static/js/ascii-breakout.min.js static/js/ascii-breakout.js
	ghp-import -p static/

wcoffee:
	coffee -o static/js -cw coffee/
wsass:
	sass --watch sass:static/css
