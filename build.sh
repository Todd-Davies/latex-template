#!/bin/bash

compileall=

while [ "$1" != "" ]; do
    case $1 in
        -a | --compileall )     compileall=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

aspell -t check content.tex
aspell -t check meta.tex

if [ "$compileall" = "1" ]; then
  directories=(diagrams);
  for dir in "${directories[@]%*/}"; do
    cd $dir;
    for i in `ls *.tex`; do
      pdflatex $i;
    done;
    cd ..
  done;
fi
pdflatex notes.tex
pdflatex kindle.tex
# In case the Author field isn't set
exiftool notes.pdf -Author="Todd Davies"
