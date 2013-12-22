#!/bin/bash
aspell -t check content.tex
aspell -t check meta.tex
pdflatex notes.tex
pdflatex kindle.tex
