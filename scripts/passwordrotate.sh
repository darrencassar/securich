#!/bin/bash

#IP
IP=127.0.0.1
#PORT
PORT=3306
# script to send simple email
# email subject
SUBJECT="testing"
# Email text/message
EMAILMESSAGE="email/email.body"

mysql -u root -h $IP -P $PORT -D securich  -e "
   select us.USERNAME,us.EMAIL_ADDRESS
   from sec_users us join sec_us_ho usho join (
      select *
      from sec_us_ho_profile
      where UPDATE_TIMESTAMP < ADDDATE(NOW(), INTERVAL -30 DAY) and TYPE='USER'
      ) pr
   where us.ID=usho.US_ID and usho.ID=pr.US_HO_ID
" --skip-column-names > email.list

IFS=$'\n'
for line in $(cat email.list)
do
   NAME=`echo $line | cut -f 1`
   EMAIL_ADDRESS=`echo $line | cut -f 2`
   # send an email using /bin/mail
   echo -e "Dear " $NAME",\n\nKindly change your MySQL password on " $IP " at port " $PORT " as it has exceeded 1 month since the last change.\nPlease note that you can not use any of the last 5 passwords and that you can change your password not more than 10 times in 1 day.\nIf you have any queries, kindly drop an email to 'dba@domain.com'.\n\nKind regards,\n\nDBA-TEAM" > email/email.body

   mail -s "$SUBJECT" "$EMAIL_ADDRESS" < $EMAILMESSAGE
done