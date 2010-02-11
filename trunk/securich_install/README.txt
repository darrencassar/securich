Baby proof install script readme:

#####################################################################
#### Make sure you have mysql, wget, gunzip and tar in your PATH ####
#####################################################################

tar -xf securich_install.tar
cd securich_install
chmod +x securich_install.sh
./securich_install.sh

Steps involved
1. enter version number when enquired "obtainable from http://www.securich.com/downloads.html or http://code.google.com/p/securich/downloads/list"
2. choose from install from file or download and install (recommended)
3. choose fresh install or upgrade
4. choose whether you'd like to import users and privileges to securich from mysql or just start from a clean state
5. enter mysql root password when prompted
6. choose whether to connect using a local socket file or via tcp
7. enter mysql hostname and port OR socket when prompted

enjoy!




