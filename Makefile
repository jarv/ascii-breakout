BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/static

serve:
	cd $(OUTPUTDIR); python -m SimpleHTTPServer 5555

github: 
	echo "ascii-breakout.com" > $(OUTPUTDIR)/CNAME
	ghp-import -p static/

wcoffee:
	coffee -o static/js -cw coffee/
wsass:
	sass --watch sass:static/css
