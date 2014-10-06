for i in `ls *.tex`; do
    aspell -t check $i.tex;
done;
zip -r content.zip ./ -x *.git*
ssh -p 51995 root@95.138.180.152 'rm -rf ~/tmp/latex_build; mkdir -p ~/tmp/latex_build;'
scp -P 51995 content.zip root@95.138.180.152:~/tmp/latex_build
ssh -p 51995 root@95.138.180.152 "cd ~/tmp/latex_build/;unzip content.zip;rm content.zip;./build.sh -n;zip content.zip ./*.pdf;"
rm content.zip
scp -P 51995 root@95.138.180.152:~/tmp/latex_build/content.zip ./content.zip
unzip -o content.zip
rm content.zip