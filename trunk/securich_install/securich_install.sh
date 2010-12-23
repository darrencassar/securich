#!/bin/bash

##################################################################################
##                                                                              ##
##  Securich install script containing selection of kind of installation such   ##
##  as through download or from file, version control, upgrade facility,        ##
##  socket or tcp/ip connection etc                                             ##
##  v 3.0                                                                       ##
##  19th August 2010                                                            ##
##                                                                              ##
##################################################################################

## Early termination of script through traps taken care of by rollbacking

terminate () {

   if [ "$CH" == "" ] || [ "$CH" == "1"  ]
    then
     mysql --user=$SUPERUSER --password=$PASS -h $HOST -P $PORT --execute="drop database if exists securich"
     mysql --user=$SUPERUSER --password=$PASS -h $HOST -P $PORT --execute="create database securich"

## If the choice was to update, then a rollback involves reloading old securich database

       if [ "$FOU" == "2" ]
       then

## load backup

         mysql --user=$SUPERUSER --password=$PASS -h $HOST -P $PORT securich < backup/securich_`/bin/date +%Y%m%d`.sql
         if [ $? != 0 ]
          then

## backup failed .... needs manual fixing

           echo "***** MAJOR PROBLEM - Rollback not possible. Backup file is in backup folder, please import manually."
           exit 1
         fi
       fi
     echo "Installation terminated abruptly and installation reversed"
     exit 0

## Same as above but for sockets rather than for tcp/ip connectivity

   elif [ "$CH" == "2" ]
    then
     mysql --user=$SUPERUSER --password=$PASS --socket=$SOCK --execute="drop database if exists securich"
     mysql --user=$SUPERUSER --password=$PASS --socket=$SOCK --execute="create database securich"

       if [ "$FOU" == "2" ]
       then
         ##load backup
         mysql --user=$SUPERUSER --password=$PASS --socket=$SOCK securich < backup/securich_`/bin/date +%Y%m%d`.sql
         if [ $? != 0 ]
          then
           echo "***** MAJOR PROBLEM - Rollback not possible. Backup file is in backup folder, please import manually."
           exit 1
         fi
       fi
     echo "Installation terminated abruptly and installation reversed"
     exit 0
   else
     echo "Installation terminated abruptly and installation reversed"
    exit 0
   fi

}

ARGUMENT=$1

if [ -z "$1" ]
  then
    ARGUMENT=notsilent
fi

if [ "$ARGUMENT" != "silent" ]
then
  ## Catering for traps ... hindering a messed up securich
  echo "                                                             "
  echo "                                                 __          "
  echo "                                      __        /\ \         "
  echo "   ____     __    ___   __  __  _ __ /\_\    ___\ \ \___     "
  echo "  /',__\  /'__ \ /'___\/\ \/\ \/\ '__\/\ \  /'___\ \  _  \   "
  echo " /\__,  \/\  __//\ \__/\ \ \_\ \ \ \/ \ \ \/\ \__/\ \ \ \ \  "
  echo " \/\____/\ \____\ \____/\ \____/\ \_\  \ \_\ \____/\ \_\ \_\ "
  echo "  \/___/  \/____/\/____/ \/___/  \/_/   \/_/\/____/ \/_/\/_/ "
  echo "                                                             "
  echo " brought to you by Darren Cassar "
  echo " http://www.mysqlpreacher.com "
  echo ""
  echo " installer version 4.0"
  echo " release date 15th January 2011"
  echo ""
  echo ""
  echo "Anytime you need to cancel installation just press ( Ctrl + C )"
  echo ""
  echo ""
fi

## Checking if mysql binary is available

 MYSQLBIN=`which mysql 2> /dev/null`
 if [ "$MYSQLBIN" = "" -o ! -x "$MYSQLBIN" ]
 then
   echo "It seems this installed can't find MYSQL binary."
   echo "Please make sure it is in your system by running 'mysql --version'"
   exit 1
 fi

## Checking if gunzip is available

 GUNZIPBIN=`which gunzip 2> /dev/null`
 if [ "$GUNZIPBIN" = "" -o ! -x "$GUNZIPBIN" ]
 then
   echo "It seems this installed can't find GUNZIP binary."
   echo "Please make sure it is in your system by running 'gunzip --version'"
   exit 1
 fi

## Checking if tar is available

 TARBIN=`which tar 2> /dev/null`
 if [ "$TARBIN" = "" -o ! -x "$TARBIN" ]
 then
   echo "It seems this installed can't find TAR binary."
   echo "Please make sure it is in your system by running 'tar --version'"
   exit 1
 fi

## Version control - suggested

 LV=`tail -1 version`                                                  ## LV = Latest Version
 BASEDIR=`pwd`

## Create logs folder to keep logs of the installation.

 if [ ! -d logs ]
  then
   mkdir logs
 fi

 echo ""
 echo -n "Enter version number (default $LV i.e. latest version): "
 read -e VN                                                            ## VN = Version Number
    if [ "$VN" == "" ]
    then
     VN=$LV
   fi

 CVN=`grep -c $VN version`                                             ## CVN = Count Version Number

## Unless user input is a correct version number, the script will keep on asking

 while [ $CVN -lt 1 ]
 do
  CVN=`grep -c $VN version`
  if [ $CVN == 0 ]
   then
    echo ""
    echo -n "Wrong value, please re-enter version number (default $LV i.e. latest version): "
     read -e VN
      if [ "$VN" == "" ]
       then
        VN=$LV
      fi
  fi
 done

## Choose if installation should get the file from the net or just install it from a  local file.

 echo ""
 echo "Which kind of installation would you like to do?"
 echo "1. Install from file on disk "
 echo "2. Download and install (recommended) "
 echo -n "Enter choice (default 2): "
 read -e TOI                                                                  ## TOI = Type of Installation

 if [ "$TOI" == "" ]
  then
    TOI=2
 fi

 while [ "$TOI" -lt "1" ] && [ "$TOI" -gt "2" ]
 do
    echo -n "Wrong value, please re-enter choice (default 2 i.e. Download and install): "
     read -e TOI
      if [ "$TOI" == "" ]
       then
        TOI=2
      fi
 done

 if [ "$TOI" == "2" ]
  then
    echo "Installation starting"

## Depending on type of OS, use wget, fetch or curl to download the package

    OS=`uname -a | cut -d ' ' -f 1`
    if [ "$OS" == "Linux" ] || [ "$OS" == "SunOS" ] || [ "$OS" == "FreeBSD" ] || [ "$OS" == "CYGWIN_NT-5.12" ]
    then
     wget http://securich.googlecode.com/files/securich.$VN.tar.gz
      if [ $? != 0 ]
      then
       fetch http://securich.googlecode.com/files/securich.$VN.tar.gz
        if [ $? != 0 ]
         then
          echo "Download problem, file does not exist or connection could not be established."
          exit 1
        fi
      fi
    elif [ "$OS" == "Darwin" ]
    then
     curl -o securich.$VN.tar.gz http://securich.googlecode.com/files/securich.$VN.tar.gz
      if [ $? != 0 ]
       then
        echo "Download problem, file does not exist or connection could not be established."
        exit 1
      fi
    else
     echo "OS not supported"
    fi

    if [ $? != 0 ]
     then
      echo "Download problem, file does not exist or connection could not be established."
      exit 1
    fi
  elif [ "$TOI" == "1" ]
   then
    if [ -e securich.$VN.tar.gz ]
     then
      echo "Installation starting"
     else
      echo "securich.$VN.tar.gz was not found, please place it in the same folder as this install script"
      exit 1
    fi
  else
   echo "Wrong value"
   exit 1
 fi

## Create securich directory to hold the dumped package

 if [ ! -d securich ]
  then
   mkdir securich
 fi

 cp -f securich.$VN.tar.gz securich
  if [ $? != 0 ]
   then
    echo "Problem encountered ... exiting"
    exit 1
  fi

 cd securich

 gunzip -f securich.$VN.tar.gz
   if [ $? != 0 ]
    then
     echo "Problem encountered ... exiting"
     exit 1
   fi

 tar -xf securich.$VN.tar
  if [ $? != 0 ]
   then
    echo "Problem encountered ... exiting"
    exit 1
  fi

 cd securich.$VN

## Choose from fresh installation or upgrade

 echo ""
 echo "Do you wish to:"
 echo "1. Do a fresh install "
 echo "2. Upgrade from a previous version "
 echo -n "Enter choice (default 1): "
 read -e FOU                                                           ## FOU = Fresh install or Upgrade

  if [ "$FOU" == "" ]
   then
    FOU=1
  fi

 while [ "$FOU" -lt "1" ] && [ "$FOU" -gt "2" ]
 do
    echo -n "Wrong value, please re-enter choice (default 1 i.e. fresh installation): "
     read -e FOU
      if [ "$FOU" == "" ]
       then
        FOU=1
      fi
 done


 echo ""
 echo -n "Enter mysql installation user username (default 'root'): "
 read -e SUPERUSER

 if [ "$SUPERUSER" == "" ]
   then
   SUPERUSER=root
 fi

## Enter password (masked for security)

 echo ""
 echo -n "Enter mysql $SUPERUSER Password (default ''): "

 stty_orig=`stty -g`
 trap "echo ''; echo 'Installation aborted during password entry'; stty $stty_orig ; exit" 1 2 15
 stty -echo
 read -e PASS
 stty $stty_orig
 trap "" 1 2 15

## Choose from TCP/IP or Socket file

 echo ""
 echo "Would you like to connect using:"
 echo "1. TCP/IP"
 echo "2. Socket file"
 echo -n "Enter choice (default 1): "
 read -e CH                                                           ## CH = Connection Handler

 if [ "$CH" == "" ]
   then
   CH=1
 fi

 while [ "$CH" -lt "1" ] && [ "$CH" -gt "2" ]
 do
    echo -n "Wrong value, please re-enter choice (default 1 i.e. TCP/IP): "
     read -e CH
      if [ "$CH" == "" ]
       then
        CH=1
      fi
 done

 if [ "$CH" == "" ] || [ "$CH" == "1"  ]
 then
    echo -n "Enter mysql Hostname/IP (default '127.0.0.1'): "
    read -e HOST
    if [ "$HOST" == "" ]
    then
       HOST=127.0.0.1
    fi
    echo -n "Enter mysql Port (default '3306'): "
    read -e PORT
    if [ "$PORT" == "" ]
    then
       PORT=3306
    fi

    COMM_MEANS=`echo "--host=$HOST --port=$PORT "`

 elif [ "$CH" == "2" ]
 then
    SOCK=inexisting_file
    while [ ! -e $SOCK ]
    do
       echo ""
       echo -n "Enter mysql socket (default '/tmp/mysql.sock'): "
       read -e SOCK
       if [ "$SOCK" == "" ]
       then
          SOCK=/tmp/mysql.sock
       fi

    COMM_MEANS=`echo " --socket=$SOCK "`

    done
 fi

 if [ "$FOU" == 1 ]
 then

## Import securich db into the instance

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS --execute="drop database if exists securich"
          innodbyes=`mysql -u $SUPERUSER --password=$PASS -s -B $COMM_MEANS --execute="show engines" | cut -f 1,2 | grep InnoDB | cut -f 2`

          if [ "$innodbyes" = 'YES' ]; then
          {
             mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS < db/securich.sql
          }
          else
          {
             mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS < db/securich_noinnodb.sql
          }
          fi

          if [ $? != 0 ]; then
           {
             echo "Problem creating securich db"
             exit 1
           }
          fi

## Import first stored procedure (used during installation)

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich < procedures/update_databases_tables_storedprocedures_list.sql
          if [ $? != 0 ]; then
           {
             echo "Problems importing procedure update_databses_tables_storedprocedures_list"
             exit 1
           }
          fi

## Create first sets of data in tables (2 simple roles, list of privileges etc)

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich < db/data.sql
          if [ $? != 0 ]; then
           {
             echo "Problems importing data into securich db"
             exit 1
           }
          fi

## Import all stored procedures into the database

          for proc in `ls procedures/`
           do
            mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich < procedures/$proc
            if [ $? != 0 ]; then
             {
               echo "Problem importing procedure $proc into securich db"
               exit 1
             }
            fi
          done

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS --execute="insert into securich.sec_version (VERSION,UPDATED_TIMESTAMP) values ('$VN',now())"

## Run reconciliation to populate securich database

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich --execute="call mysql_reconciliation('')"

## If upgrading, run upgrade scripts

 elif [ "$FOU" == 2 ]
 then

## Create backups folder to backup securich db in.
## This is just a precaution to be able to rollback in case there is a problem

   if [ ! -d backup ]
    then
     mkdir backup
   fi

   UST=0                                                              ## UST = Upgrade STarted

## CURV = Current Version

          CURV=`mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich --execute="select VERSION from sec_version order by ID desc limit 1" | tail -1`
            if [ $? != 0 ]; then
             {
               CURV=0.1.1
             }
            fi

## If version requested is older than current version then upgrade is not possible

          if [ `sed -n "/$VN/,/$LV/p" $BASEDIR/version | grep -c $CURV` != 0 ]       ## New Or Old
          then
            echo "Upgrading a recent version $CURV with the same or older version $VN is not possible"
            exit 0
          fi

## Backup securich db in case we need to rollback

          mysqldump -q --add-drop-table --single-transaction --no-autocommit --user=$SUPERUSER --password=$PASS $COMM_MEANS securich > backup/securich_`/bin/date +%Y%m%d`.sql

          echo ""
          echo "MySQL Security database backup taken"
          echo ""

## Upgrade version of securich
## UST is the flag which if enabled means we need to restore securich db as upgrade messed things up already (because UST means the upgrade had already been started)

          UST=1

          for VERSION in `sed -n "/$CURV/,/$LV/p" $BASEDIR/version | grep -v $CURV`
          do
            mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich < upgrades/$VERSION/upgrade.sql
            if [ $? != 0 ]; then
             {
               echo "Problem updating securich db"
               exit 1
             }
            fi
          done

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich < procedures/update_databases_tables_storedprocedures_list.sql
          if [ $? != 0 ]; then
           {
             echo "Problems importing procedure update_databses_tables_storedprocedures_list"
             exit 1
           }
          fi

          for proc in `ls procedures/`
           do
            mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS securich < procedures/$proc
            if [ $? != 0 ]; then
             {
               echo "Problem importing procedure $proc into securich db"
               exit 1
             }
            fi
          done

          mysql --user=$SUPERUSER --password=$PASS $COMM_MEANS --execute="insert into securich.sec_version (VERSION,UPDATED_TIMESTAMP) values ('$VN',now())"

 else
  echo "Wrong value for type of installation selected, please enter 1 or 2."
 fi

 echo "Installation complete"