#!/bin/bash

#######################################################################################
##                                                                                   ##
##   This is a script used to email users about password expiry                       ##
##                                                                                   ##
##   This program was written by Darren Cassar 2009.                                 ##
##   Feedback and improvements are welcome at:                                       ##
##   info [at] securich.com / info [at] mysqlpreacher.com                            ##
##                                                                                   ##
##   THIS PROGRAM IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED             ##
##   WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF            ##
##   MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.                           ##
##                                                                                   ##
##   This program is free software; you can redistribute it and/or modify it under   ##
##   the terms of the GNU General Public License as published by the Free Software   ##
##   Foundation, version 2.                                                          ##
##                                                                                   ##
##   You should have received a copy of the GNU General Public License along with    ##
##   this program; if not, write to the Free Software Foundation, Inc., 59 Temple    ##
##   Place, Suite 330, Boston, MA  02111-1307  USA.                                  ##
##                                                                                   ##
#######################################################################################

USER=root
PASSWORD=
HOSTNAME=127.0.0.1
HOST=`hostname`
PORT=3306
PERIOD=30
# script to send simple email
# email subject
SUBJECT="testing"
# Email text/message
EMAILMESSAGE="email.body"
EMAILLIST="email.body"

#######################################################################################
# Don't change anything below this line unless you are sure about what you are doing  #
#######################################################################################

mysql -u$USER -p$PASSWORD -h$HOSTNAME -P$PORT -D securich  -e "
   select us.USERNAME,us.EMAIL_ADDRESS
   from sec_users us join sec_us_ho usho join (
      select *
      from sec_us_ho_profile
      where UPDATE_TIMESTAMP < ADDDATE(NOW(), INTERVAL -$PERIOD DAY) and TYPE='USER'
      ) pr
   where us.ID=usho.US_ID and usho.ID=pr.US_HO_ID
" --skip-column-names > $EMAILLIST

IFS=$'\n'
for line in $(cat $EMAILLIST)
do
   NAME=`echo $line | cut -f 1`
   EMAIL_ADDRESS=`echo $line | cut -f 2`
   # send an email using /bin/mail
   echo -e "Dear " $NAME",\n\nKindly change your MySQL password on - " $HOST " - at port - " $PORT " - as it has exceeded 1 month since the last change.\nPlease note that you can not use any of the last 5 passwords and that you can change your password not more than 10 times in 1 day.\nIf you have any queries, kindly drop an email to 'dba@domain.com'.\n\nKind regards,\n\nDBA-TEAM" > $EMAILMESSAGE

   mail -s "$SUBJECT" "$EMAIL_ADDRESS" < $EMAILMESSAGE
done
