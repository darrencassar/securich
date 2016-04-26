# Introduction #

Securich only requires little resources and a few applications like _mysql_, _wget_, _tar_, _gzip_. It is pretty straight forward and offers quite a few options like installing it on remote machines, upgrading, error handling, etc

# Installing Securich #
## Using the install script ##
The recommended way to go about when installing the package is to download the installer script `wget http://www.securich.com/downloads/securich_install.tar` which you simply have to untar and run. The script will ask a few questions tipo:
  1. Which version you want to install
  1. Would you prefer to download the latest copy or use a readily available .tar.gz file
  1. Would you like to upgrade securich or just run a fresh install

Always make sure you are running the latest install script.
When in doubt download the latest tar file from the downloads page.

### Requirements ###

**Make sure you have mysql, wget, gunzip and tar in your PATH**

> 
---

## Manual installation ##
If you'd like to install the latest version (in development / testing):
```
> svn checkout http://securich.googlecode.com/svn/trunk/ securich-read-only  
> cd securich
> mysql -u root --execute="drop database if exists securich"
> mysql -u root securich < db/securich.sql
> mysql -u root securich < procedures/update_databases_tables_storedprocedures_list.sql
> mysql -u root securich < db/data.sql

> for proc in `ls procedures/`
> do
> mysql -u root securich < procedures/$proc
> done 
```
If at this point you'd like to import any MySQL accounts in the Securich db issue:
```
> mysql -u root securich < --execute="call reverse_reconciliation()"
```

# Uninstalling #

Uninstalling securich is as simple as a few key strokes -- it's basically as easy as a `drop securich;` on the MySQL instance it is installed on.