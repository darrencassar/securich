rm -rf securich.0.5
cp -rp securich securich.0.5
cd securich.0.5
rm -rf testing
rm -rf securich_install
rm -rf release
rm -rf `find . -name .DS_Store`
rm -rf `find . -name .svn`
find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g' > manifest.tmp
sed 's/| /|     /g' manifest.tmp | sed 's/|_/|______/g' > MANIFEST.txt
rm manifest.tmp
cat MANIFEST.txt | grep -v manifest.tmp > MANIFEST2.txt
mv MANIFEST2.txt MANIFEST.txt
cd ..
tar -cf securich.0.5.tar securich.0.5
gzip -6 securich.0.5.tar
