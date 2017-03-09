all:	stead3.pdf

manual.tex: manual.md
	multimarkdown manual.md -t latex -o manual.tex

stead3.pdf: stead3.tex manual.tex
	xelatex stead3.tex
	xelatex stead3.tex

clean:
	rm -f *.pdf *.aux *.log *.out *.toc manual.tex
