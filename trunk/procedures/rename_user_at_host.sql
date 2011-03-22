#######################################################################################
##                                                                                   ##
##   This is rename_user_at_host, a script used to rename a particular user@host.    ##
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

DROP PROCEDURE IF EXISTS rename_user_at_host;

DELIMITER $$


CREATE PROCEDURE `securich`.`rename_user_at_host`( usernamein varchar(16), hostnamein varchar(16), newusernamein varchar(16), newhostnamein varchar(16))
  BEGIN

      DECLARE userexists INT;
      DECLARE hostexists INT;

      DECLARE newuserexists INT;
      DECLARE newhostexists INT;
      DECLARE usernameincount INT;
      DECLARE newusernameincount INT;
      
      DECLARE userathostexists INT;
      DECLARE newuserathostexists INT;
      
      DECLARE newhostid INT;
      DECLARE newuserid INT;
      DECLARE oldhostid INT;
      DECLARE olduserid INT;

      DECLARE done INT DEFAULT 0;

      FLUSH PRIVILEGES;
      call reconciliation('sync');
                      /* Security feature does not permit an empty user / root user being granted through this package! */

      SET usernameincount = (select count(*) from sec_reserved_usernames where USERNAME=usernamein);
      SET newusernameincount = (select count(*) from sec_reserved_usernames where USERNAME=newusernamein);
      
      IF usernameincount > 0 THEN

         select "Illegal username entry - username is reserved." as ERROR;

      ELSEIF newusernameincount > 0 THEN

         select "Illegal new username entry - username is reserved." as ERROR;

      ELSE

         SET userexists = (
            select count(*)
            from sec_users
            where USERNAME=usernamein
            );

         SET newuserexists = (
            select count(*)
            from sec_users
            where USERNAME=newusernamein
            );
            
         SET hostexists = (
            select count(*)
            from sec_hosts
            where HOSTNAME=hostnamein
            );

         SET newhostexists = (
            select count(*)
            from sec_hosts
            where HOSTNAME=newhostnamein
            );
            
         SET userathostexists = (
            select count(*)
            from sec_us_ho 
               join ( select id 
                      from sec_users 
                      where USERNAME=usernamein ) us_id
               join ( select id 
                      from sec_hosts 
                      where HOSTNAME=hostnamein ) ho_id
            where sec_us_ho.us_id=us_id.id and
            sec_us_ho.ho_id=ho_id.id
            );
            
         SET newuserathostexists = (
            select count(*)
            from sec_us_ho 
               join ( select id 
                      from sec_users 
                      where USERNAME=newusernamein ) us_id
               join ( select id 
                      from sec_hosts 
                      where HOSTNAME=newhostnamein ) ho_id
            where sec_us_ho.us_id=us_id.id and
            sec_us_ho.ho_id=ho_id.id
            );            
            
            
         IF userathostexists < 1 THEN
            select "Source username at hostnmae does not exist" as ERROR;
         ELSEIF newuserathostexists > 0 THEN
            select "Destination username at hostname already exists" as ERROR;
         ELSE
            IF newhostexists < 1 THEN
               insert into sec_hosts (HOSTNAME) value (newhostnamein);
            END IF;
            
            IF newuserexists < 1 THEN
               insert into sec_users (USERNAME) value (newusernamein);
            END IF;
            
            set olduserid=(select ID from sec_users where USERNAME=usernamein);
            set oldhostid=(select ID from sec_hosts where HOSTNAME=hostnamein);

            set newuserid=(select ID from sec_users where USERNAME=newusernamein);
            set newhostid=(select ID from sec_hosts where HOSTNAME=newhostnamein);
                        
            update sec_us_ho set HO_ID=newhostid , US_ID=newuserid where HO_ID=oldhostid and US_ID=olduserid;
            update sec_us_ho_db_tb set HO_ID=newhostid , US_ID=newuserid where HO_ID=oldhostid and US_ID=olduserid;
            update sec_us_ho_db_sp set HO_ID=newhostid , US_ID=newuserid where HO_ID=oldhostid and US_ID=olduserid;

            call reconciliation('securichsync');
            
            SET @d = CONCAT('drop user "', usernamein , '"@"' , hostnamein , '"'); /* Drop since the user doesn't have any privileges at all! */

	        PREPARE dropcom FROM @d;
		    EXECUTE dropcom;
		
            SET @g = CONCAT('User "', usernamein , '"@"' , hostnamein , '" renamed to "', newusernamein , '"@"' , newhostnamein , '"');
		
		    SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
            SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
            INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());
  
            
         END IF;

      END IF;

END$$

DELIMITER ;
