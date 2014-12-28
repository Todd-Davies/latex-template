#!/bin/bash

server=95.138.180.152
port=51995
username=root

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

# This will only work if you've got access to the remote server.
if [ "$remote" = 1 ]; then
  zip -r content.zip ./ -x *.git*
  ssh -p $port $username@$server 'rm -rf ~/tmp/latex_build; mkdir -p ~/tmp/latex_build;'
  scp -P $port content.zip $username@$server:~/tmp/latex_build
  ssh -p $port $username@$server "cd ~/tmp/latex_build/;unzip content.zip;rm content.zip;./build.sh -a;zip content.zip ./*.pdf;"
  rm content.zip
  scp -P $port $username@$server:~/tmp/latex_build/content.zip ./content.zip
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