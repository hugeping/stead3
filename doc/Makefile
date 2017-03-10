all:	stead3.pdf

stead3-manual.tex: stead3.md
	multimarkdown stead3.md -t latex -o stead3-manual.tex

stead3.pdf: stead3.tex stead3-manual.tex
	xelatex stead3.tex
	xelatex stead3.tex
	xelatex stead3.tex

clean:
	rm -f *.pdf *.aux *.log *.out *.toc stead3-manual.tex
