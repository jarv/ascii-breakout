BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/static
github: 
	echo "ascii-breakout.com" > $(OUTPUTDIR)/CNAME
	ghp-import -p static/
