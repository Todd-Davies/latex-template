#!/bin/bash

compileall=
remote=

function usage
{
  echo "usage: build.sh [-a -r ]"
}

while [ "$1" != "" ]; do
    case $1 in
        -a | --compileall )     compileall=1
                                ;;
        -r | --remote )         remote=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     exit 1
    esac
    shift
done

for i in `ls *.tex`; do
    aspell -t check $i;
done;

if [ "$remote" = 1 ]; then
  zip -r content.zip ./ -x *.git*
  ssh -p 51995 root@95.138.180.152 'rm -rf ~/tmp/latex_build; mkdir -p ~/tmp/latex_build;'
  scp -P 51995 content.zip root@95.138.180.152:~/tmp/latex_build
  ssh -p 51995 root@95.138.180.152 "cd ~/tmp/latex_build/;unzip content.zip;rm content.zip;./build.sh -n;zip content.zip ./*.pdf;"
  rm content.zip
  scp -P 51995 root@95.138.180.152:~/tmp/latex_build/content.zip ./content.zip
  unzip -o content.zip
  rm content.zip
else
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
  if [ "$compileall" = "1" ]; then
    pdflatex kindle.tex
  fi
  # In case the Author field isn't set
  exiftool notes.pdf -Author="Todd Davies"
fi