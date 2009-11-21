cp -rp securich securich.0.2.0
cd securich.0.2.0
rm -rf testing
rm -rf securich_install
rm -rf release
rm securich.bbproject
rm -rf .DS_Store
rm -rf `find . -name .svn`
find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g' > manifest.tmp
sed 's/| /|     /g' manifest.tmp | sed 's/|_/|______/g' > MANIFEST.txt
rm manifest.tmp
cat MANIFEST.txt | grep -v manifest.tmp > MANIFEST2.txt
mv MANIFEST2.txt MANIFEST.txt
cd ..
tar -cf securich.0.2.0.tar securich.0.2.0
gzip -9 securich.0.2.0.tar
