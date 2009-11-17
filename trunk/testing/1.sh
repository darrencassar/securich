#!/bin/bash

#=============================================================================
# Paramters - Set up variables for script
#=============================================================================

USER=root
PASSWORD=msandbox
HOST=127.0.0.1
PORT=5137
DB=securich
LOGERR=securich_test.err
LOGFILE=securich_test.log

#=============================================================================
# TestParamters
#=============================================================================

DBUSER=terri104
DBHOST=127.0.0.1
ROLENAME=roleabf


#=============================================================================
# Logging - Redirect IO to LOGERR and LOGFILE
#=============================================================================

if [ ! -e "$LOGFILE" ]          # Check if LOGFILE exists.
   then
   touch $LOGFILE
fi

if [ ! -e "$LOGERR" ]           # Check if LOGFERR exists.
   then
   touch $LOGERR
fi

exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
exec >> $LOGFILE    # stdout replaced with file $LOGFILE.

exec 6>&2           # Link file descriptor #6 with stderr.
                    # Saves stderr.
exec 2> $LOGERR     # stderr replaced with file $LOGERR.

cat /dev/null > $LOGERR
cat /dev/null > $LOGFILE


#=============================================================================
# Execution - Commands executed and logged for analysis
#=============================================================================

# Test1
#========

echo ""
echo -e `date` - "\033[1mINFO - TEST CREATE USER\033[0m"
echo ""
echo -e `date` - "\033[1mINFO - Starting grant privileges\033[0m"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('$DBUSER','$DBHOST','securich','sec_users','singletable','update','darren.cassar@tradingscreen.com')"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - grant_privileges\033[0m"
} fi

TESTUSER=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Testing new user access\033[0m"
echo ""

mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="show databases"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show databases\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Testing select now()\033[0m"
echo ""

mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - select now()\033[0m"
} fi

echo ""
echo ""
echo ""

# Test2 
#============

echo -e `date` - "\033[1mINFO - TEST CREATE ROLE\033[0m"

echo -e `date` - "\033[1mINFO - Starting creating $ROLENAME\033[0m"
mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','$ROLENAME','select');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - role create with priv select\033[0m"
} fi

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','$ROLENAME','insert');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - role create with priv insert\033[0m"
} fi

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','$ROLENAME','update');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - role create with priv update\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing roles available\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_roles();"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_roles\033[0m"
} fi
 
echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing roles\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_privileges_in_roles('$ROLENAME');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_privileges_in_roles\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing privileges belonging to role $ROLENAME\033[0m"



#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.






call create_update_role('role1','select');
call create_update_role('role1','insert');
call create_update_role('role1','update');
call show_roles();
call show_privileges_in_roles('role1');
call grant_privileges('john' , 'machine.domain.com' , 'employees' , '' , 'alltables' , 'role1' , 'john@domain.com');
call revoke_privileges('john' , 'machine.domain.com' , 'employees' , 'salaries' , 'table' , 'role1' , 'N');
call grant_privileges('paul' , '10.0.0.2' , 'world' , '^Country' , 'regexp' , 'role1' , 'paul@domain.com');
call grant_privileges('peter' , 'localhost' , 'test' , '' , 'all' , 'role1' , 'peter@domain.com');
call show_full_user_entries('paul');
call create_update_role('role1','delete');
call show_full_user_entries('paul');
call set_password('paul' , '10.0.0.2' , 'password123');
call clone_user('paul' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');
call show_full_user_entries('judas');
call show_user_privileges('judas' , '10.0.0.2' , 'world' , 'role1');
call rename_user('judas' , 'james' , 'james@domain.com');
call create_update_role('role2','execute');
call grant_privileges('peter' , 'localhost' , 'securich' , 'my_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');

Connect to mysql using thirduser peter in another session:
    show databases;
    use securich;
    show tables;
    call my_privileges('test');
    show processlist;

call revoke_privileges('peter' , 'localhost' , 'test' , '' , '' , 'role1' , 'Y');


