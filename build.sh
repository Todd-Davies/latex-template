#!/bin/bash

if [ -s config.sh ]; then
  source config.sh
else
  echo "No config.sh!";
fi

# Define the command line arguments
compileall=
remote=
fastArgs=""

function usage
{
  echo "usage: build.sh [-a -r -f]"
  echo "  -a (Re)Compile all diagrams, kindle versions etc (slow!)"
  echo "  -r Compile on a remote server"
  echo "  -f Compile quickly (maybe taking shortcuts along the way)"
  echo "  -s Compile serially (no parallel compilation)"
}

while [ "$1" != "" ]; do
    case $1 in
        -a | --compileall )     compileall=1
                                ;;
        -r | --remote )         remote=1
                                ;;
        -f | --fast )           fastArgs="\def\fastCompile{1} "
                                ;;
        -s | --serial )         parallelCompile=0
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     exit 1
    esac
    shift
done

# Runs this script on the remote host
function remoteCompile
{
  zip -r content.zip ./ -x *.git*;
  ssh -p $hostport $remoteuser@$hostname 'rm -rf ~/tmp/latex_build; mkdir -p ~/tmp/latex_build;';
  scp -P $hostport content.zip $remoteuser@$hostname:~/tmp/latex_build;
  ssh -p $hostport $remoteuser@$hostname "cd ~/tmp/latex_build/;unzip content.zip;rm content.zip;./build.sh -n;zip content.zip ./*.pdf;";
  rm content.zip;
  scp -P $hostport $remoteuser@$hostname:~/tmp/latex_build/content.zip ./content.zip;
  unzip -o content.zip;
  rm content.zip;
}

function parallelCompile()
{
  numCmd=`wc -l $1 | awk '{ print $1 }'`;
  cat $1 | parallel bash -c "{} >> $logFile && echo done" | pv -p -l -s $numCmd -N "$2" > /dev/null;
}

# Spell check all the things!
# TODO(td): Implement optional whitelist for spellchecking
for i in `ls *.tex`; do
    aspell -t check $i;
done;

if [ -s $preCompileCommands ]; then
  rm $preCompileCommands
fi
touch $preCompileCommands;
if [ -s $commands ]; then
  rm $commands
fi
touch $commands;

if [ "$remote" = 1 ]; then
  remoteCompile;
else
  if [ "$compileall" = 1 ]; then
    for dir in "${directories[@]%*/}"; do
      for i in `ls $dir/*.tex`; do
        echo "pdflatex "`pwd`"/$i" > $preCompileCommands;
      done;
    done;
    # Compile the kindle notes if we're doing everything
    echo "pdflatex -shell-escape $fastArgs\"\input{kindle.tex}\"" >> $commands;
  fi
  # Compile the main notes file
  echo "pdflatex -shell-escape $fastArgs\"\input{notes.tex}\"" >> $commands;
  if [ $parallelCompile = 1 ]; then
    if [ -s $logFile ]; then 
      rm $logFile;
    fi
    if [ -s $preCompileCommands ]; then
      parallelCompile $preCompileCommands "Compiling reosurces:";
    fi
    parallelCompile $commands "Compiling output:";
  else
    if [ -s $preCompileCommands ]; then
      bash $preCompileCommands;
    fi
    bash $commands;
  fi
  # In case the Author field isn't set
  #exiftool notes.pdf -Author='$authorName' >> $logFile;
fi