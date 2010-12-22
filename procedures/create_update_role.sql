#######################################################################################
##                                                                                   ##
##   This is create_update_role, used to add/remove privileges to/from roles.        ##
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

USE securich;

DELIMITER $$

DROP PROCEDURE IF EXISTS `securich`.`create_update_role`$$

CREATE PROCEDURE `create_update_role`( way varchar(12), rolenamein varchar(64), privilegenamein varchar(64))
BEGIN

    DECLARE ROLE_ID INT;
    DECLARE PRIV_ID INT;
    DECLARE roleprivilegeexists INT;
    
    IF (select count(*) from sec_privileges where PRIVILEGE=privilegenamein) = 1 THEN
    
		IF (select count(*) from sec_roles where ROLE=rolenamein) < 1 THEN
		   insert into sec_roles (ROLE) values (rolenamein);
		END IF;
	
		IF (select count(*) from sec_privileges where PRIVILEGE=privilegenamein) < 1 THEN
		   select "Privilege entered does not exist!";
		ELSE
	
		   SET ROLE_ID = (select ID from sec_roles where ROLE=rolenamein);
		   SET PRIV_ID = (select ID from sec_privileges where PRIVILEGE=privilegenamein);
	
		   /* Check if the role spedivied already contains the privilege specified */
	
		   SET roleprivilegeexists = (
			  select count(*)
			  from sec_ro_pr
			  where RO_ID=ROLE_ID and
			  PR_ID=PRIV_ID
			  );
		   
		   SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
		   SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
		   
	
		   /* If user needs to add a privilege to a role, check that the role doesn't contain the particular privileg and if it does then issue a warning, otherwise just add it */
	
		   IF way = 'add' AND roleprivilegeexists = 0 THEN
	
			  insert into sec_ro_pr (RO_ID,PR_ID) values (ROLE_ID,PRIV_ID);
			  set @g= CONCAT("add " , privilegenamein , " to " , rolenamein );
			  IF (select value from sec_config where PROPERTY = 'mysql_to_securich_reconciliation_in_progress') = '0' THEN
				 call reconciliation('sync'); 
			  END IF;
			  INSERT INTO aud_roles (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());
	
		   ELSEIF way = 'add' AND roleprivilegeexists > 0 THEN
	
			  select "Role specified already contains the privilege requested, please use `check_role_privileges` to check which privileges already belong to a particular role";
	
		   /* If user needs to remove a privilege from a role, check that the role does contain the particular privileg and if it doesn't then issue a warning, otherwise just remove it */
	
		   ELSEIF way = 'remove' AND roleprivilegeexists > 0 THEN
	
			  delete from sec_ro_pr where RO_ID=ROLE_ID and PR_ID=PRIV_ID;
			  set @g= CONCAT("remove " , privilegenamein , " from " , rolenamein );          
			  IF (select value from sec_config where PROPERTY = 'mysql_to_securich_reconciliation_in_progress') = '0' THEN
				 call reconciliation('sync'); 
			  END IF;
			  INSERT INTO aud_roles (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());
	 
		   ELSEIF way = 'remove' AND roleprivilegeexists = 0 THEN
	
			  select "Role specified doesn't contain the privilege requested, please use `check_role_privileges` to check which privileges already belong to a particular role";
	
		   ELSE
	
			  select "Wrong 'way' specified in the procedure call. Please run `call help('create_update_role');` for further information";
	
		   END IF;
	
		END IF;
		
	ELSE
	    
	    select "Privilege does not exist";

	END IF;

  END$$

DELIMITER ;
