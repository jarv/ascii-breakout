BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/static

serve:
	cd $(OUTPUTDIR); python -m SimpleHTTPServer 5555

github: 
	echo "ascii-breakout.com" > $(OUTPUTDIR)/CNAME
	ghp-import -p static/

cwatch:
	coffee -o static/js -cw coffee/
	
