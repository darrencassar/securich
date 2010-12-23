#!/bin/bash

#=============================================================================
# Paramters - Set up variables for script
#=============================================================================

USER=root
PASSWORD=msandbox
HOST=127.0.0.1
PORT=3308
DB=securich
LOGERR=`pwd`/logs/securich_test.err
LOGFILE=`pwd`/logs/securich_test.log

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
# DBCreation - World,Employees and Sakila dbs are imported for testing
#=============================================================================

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < testing/world.sql
mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < testing/employees.sql
mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT < testing/sakila.sql


#=============================================================================
# Execution - Commands executed and logged for analysis
#=============================================================================

# Test1
#========

echo ""
echo -e `date` - "INFO - Test1 - TEST CREATE USER"
echo ""
echo -e `date` - "INFO - Test1 - Starting grant privileges"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','select');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test1 - create_update_role"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test1 - Updating role - role1, adding privilege select"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('trilla','localhost','securich','sec_users','singletable','role1','user@company.com')"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test1 - grant_privileges"
} fi

TESTUSER=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo ""
echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "INFO - Test1 - Testing new user access"
echo ""

mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="show databases"
if [ $? != 0 ]; then
{
    echo -e "ERROR - show databases"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Testing select now()"
echo ""

mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "ERROR - select now()"
} fi

echo ""
echo ""
echo ""

# Test2
#============

echo -e `date` - "INFO - Test2 - TEST CREATE ROLE"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','insert');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test2 - role create with priv insert"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test2 - Role creating with insert privilege"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','update');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test2 - role create with priv update"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test2 - Showing roles available"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_roles();"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test2 - show_roles"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test2 - Showing roles"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_privileges_in_role('role1');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test2 - show_privileges_in_role"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test2 - Showing privileges belonging to role role1"


mysql -u $TESTUSER --password=$TESTPASS -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test2 - select now()"
} fi

echo ""
echo ""
echo ""

# Test3
#============

echo -e `date` - "INFO - Test3 - TEST CREATE / DELETE USER"

echo -e `date` - "INFO - Test3 - Starting creating John@domain.com"


mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('john' , '127.0.0.1' , 'employees' , '' , 'alltables' , 'role1' , 'john@domain.com')"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - grant_privileges"
} fi

TESTUSER=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "INFO - Test3 - Testing new user access"
echo ""


mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call revoke_privileges('john' , '127.0.0.1' , 'employees' , 'salaries' , 'table' , 'role1' , 'N')"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - revoke_privileges"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Testing revoke privileges on user"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('tom' , '10.0.0.2' , 'world' , '^Country' , 'regexp' , 'role1' , 'tom@domain.com')"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - grant_privileges"
} fi

TESTUSER=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "INFO - Test3 - Testing new user access"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_full_user_entries('tom');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - show_full_user_entries"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Showing full user entries"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role1','delete');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - create_update_role"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Updating role - role1, adding privilege DELETE"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_full_user_entries('tom');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - show_full_user_entries"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Showing full user entries"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL clone_user('tom' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - clone_user"
} fi

TESTUSER=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "INFO - Test3 - Cloning user TOM to user JUDAS"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_full_user_entries('judas');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - show_full_user_entries"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Showing full user entries"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL show_user_privileges('judas' , '10.0.0.2' , 'world' , 'role1');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - show_full_user_privileges"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Showing full user privileges for JUDAS"

#mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL rename_user('judas' , 'james' , 'james@domain.com', '$TESTPASS');"
#if [ $? != 0 ]; then
#{
#    echo -e "ERROR - Test3 - rename_user"
#} fi
#
#echo ""
#echo ""
#echo -e `date` - "INFO - Test3 - Renaming User"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="CALL create_update_role('add','role2','execute');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - create_update_role"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test3 - Create Update Role"



mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - select now()"
} fi

echo ""
echo ""
echo ""


# Test4
#============

echo -e `date` - "INFO - Test4 - TEST CREATE / DELETE USER"

echo -e `date` - "INFO - Test4 - Starting creating John@domain.com"

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('peter' , 'localhost' , 'world' , '' , 'all' , 'role1' , 'peter@domain.com')"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test3 - grant_privileges"
} fi

TESTUSER=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 2 | tail -1`
TESTPASS=`cat $LOGFILE | grep 'Password for user' | tr -s "-" | sed 's/ //g' | cut -d "-" -f 6 | tail -1`

echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "INFO - Test3 - Testing new user access"
echo ""

mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call grant_privileges('peter' , 'localhost' , 'securich' , 'my_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - grant_privileges"
} fi

echo ""
echo "TESTUSER=$TESTUSER - TESTPASS=$TESTPASS"
echo ""
echo -e `date` - "INFO - Test4 - Testing new user access"
echo ""



mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT --execute="show databases"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - Peter can not show databases"
} fi


echo ""
echo -e `date` - "INFO - Test4 - Peter show databases"
echo ""


mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT securich --execute="show tables"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - Peter can not show tables"
} fi


echo ""
echo -e `date` - "INFO - Test4 - Peter show tables"
echo ""


mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT securich --execute="call my_privileges('world');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - Peter can't check his own privileges"
} fi


echo ""
echo -e `date` - "INFO - Test4 - Peter can check his own privileges"
echo ""



mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT $DB --execute="call revoke_privileges('peter' , 'localhost' , 'world' , '' , '' , 'role1' , 'Y');"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - revoke_privileges"
} fi

echo ""
echo ""
echo -e `date` - "INFO - Test4 - Testing revoke privileges on user"
echo ""


mysql -u peter --password=$TESTPASS -h 127.0.0.1 -P $PORT test --execute="show databases"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - Peter can't show databases after revoke"
} fi


echo ""
echo -e `date` - "INFO - Test4 - Peter show databases after revoke"
echo ""


mysql -u $USER --password=$PASSWORD -h $HOST -P $PORT --execute="select now()"
if [ $? != 0 ]; then
{
    echo -e "ERROR - Test4 - select now()"
} fi

echo ""
echo ""
echo ""

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.
