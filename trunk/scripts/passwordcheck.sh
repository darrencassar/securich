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

mysql -u root -h $IP -P $PORT -D securich  -e "call password_check()" > email.list
