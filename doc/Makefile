filelist := $(shell ls | grep tex | cut -d. -f1)


default:
	$(foreach filename,$(filelist),pdflatex $(filename).tex; bibtex \
	$(filename).aux; pdflatex $(filename).tex;pdflatex $(filename).tex;)
	
	rm *.log *.aux *.bbl *.blg *.dvi
clean:
	rm *.pdf *.log *.aux *.bbl *.blg *.dvi

