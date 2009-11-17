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

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('$DBUSER','$DBHOST','securich','sec_users','singletable','update','user@company.com')"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - grant_privileges\033[0m"
} fi

TESTUSER=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo "" 
echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
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

echo -e `date` - "\033[1mINFO - Starting creating role1\033[0m"
mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','select');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - role create with priv select\033[0m"
} fi

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','insert');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - role create with priv insert\033[0m"
} fi

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','update');"
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

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_privileges_in_roles('role1');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_privileges_in_roles\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing privileges belonging to role role1\033[0m"


mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - select now()\033[0m"
} fi

echo ""
echo ""
echo ""

# Test3
#============

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < employees.db
mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < word.db

echo -e `date` - "\033[1mINFO - TEST CREATE / DELETE USER\033[0m"

echo -e `date` - "\033[1mINFO - Starting creating John@domain.com\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('john' , 'domain.com' , 'employees' , '' , 'alltables' , 'role1' , 'john@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - grant_privileges\033[0m"
} fi

TESTUSER=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo "" 
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "\033[1mINFO - Testing new user access\033[0m"
echo ""


mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call revoke_privileges('john' , 'domain.com' , 'employees' , 'salaries' , 'table' , 'role1' , 'N');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - revoke_privileges\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Testing revoke privileges on user\033[0m"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('paul' , '10.0.0.2' , 'world' , '^Country' , 'regexp' , 'role1' , 'paul@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - grant_privileges\033[0m"
} fi

TESTUSER=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo "" 
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "\033[1mINFO - Testing new user access\033[0m"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('peter' , 'localhost' , 'world' , '' , 'all' , 'role1' , 'peter@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - grant_privileges\033[0m"
} fi

TESTUSER=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat securich_test.log | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo "" 
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "\033[1mINFO - Testing new user access\033[0m"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_full_user_entries('paul');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_full_user_entries\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing full user entries\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','delete');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - create_update_role\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Updating role - role1, adding privilege DELETE\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_full_user_entries('paul');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_full_user_entries\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing full user entries\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL clone_user('paul' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - clone_user\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Cloning user PAUL to user JUDAS\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_full_user_entries('judas');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_full_user_entries\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing full user entries\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_user_privileges('judas' , '10.0.0.2' , 'world' , 'role1');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_full_user_privileges\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing full user privileges\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL rename_user('judas' , 'james' , 'james@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_full_user_privileges\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing full user privileges\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('role2','execute');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - show_full_user_privileges\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Showing full user privileges\033[0m"



mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - select now()\033[0m"
} fi

echo ""
echo ""
echo ""


# Test4
#============

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < employees.db
mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < word.db

echo -e `date` - "\033[1mINFO - TEST CREATE / DELETE USER\033[0m"

echo -e `date` - "\033[1mINFO - Starting creating John@domain.com\033[0m"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('peter' , 'localhost' , 'securich' , 'my_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - grant_privileges\033[0m"
} fi


echo "" 
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "\033[1mINFO - Testing new user access\033[0m"
echo ""



mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT --execute="show databases"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - Peter can not show databases\033[0m"
} fi


echo ""
echo -e `date` - "\033[1mINFO - Peter show databases\033[0m"
echo ""


mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT securich --execute="show tables"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - Peter can not show tables\033[0m"
} fi


echo ""
echo -e `date` - "\033[1mINFO - Peter show tables\033[0m"
echo ""


mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT securich --execute="call my_privileges('test');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - Peter can't check his own privileges\033[0m"
} fi


echo ""
echo -e `date` - "\033[1mINFO - Peter can check his own privileges\033[0m"
echo ""



mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call revoke_privileges('peter' , 'localhost' , 'test' , '' , '' , 'role1' , 'Y');"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - revoke_privileges\033[0m"
} fi

echo "" 
echo ""
echo -e `date` - "\033[1mINFO - Testing revoke privileges on user\033[0m"
echo ""


mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT test --execute="show databases"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - Peter can't show databases after revoke\033[0m"
} fi


echo ""
echo -e `date` - "\033[1mINFO - Peter show databases after revoke\033[0m"
echo ""


mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "\033[1mERROR - select now()\033[0m"
} fi

echo ""
echo ""
echo ""

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.
