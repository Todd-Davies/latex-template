#!/bin/bash
aspell -t check content.tex
aspell -t check meta.tex
directories=();
for dir in "${directories[@]%*/}"; do
  cd $dir;
  for i in `ls *.tex`; do
    pdflatex $i;
  done;
  cd ..
done;
pdflatex notes.tex
pdflatex kindle.tex
# In case the Author field isn't set
exiftool notes.pdf -Author="Todd Davies"
