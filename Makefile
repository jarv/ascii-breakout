BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/static
github: 
	ghp-import $(OUTPUTDIR)
	git push origin gh-pages
	echo "ascii-breakout.com" > $(OUTPUTDIR)/CNAME
	ghp-import $(OUTPUTDIR)
	git push git@github.com:jarv/ascii-breakout.git  gh-pages -f
