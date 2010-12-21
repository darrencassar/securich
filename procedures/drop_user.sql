#######################################################################################
##                                                                                   ##
##   This is reconciliation, a script used to check and repair any differences       ##
##   between the mysql privileges tables and securich db.                            ##
##                                                                                   ##
##   This program was written by Darren Cassar 2010.                                 ##
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

DROP PROCEDURE IF EXISTS drop_user;

DELIMITER $$

CREATE PROCEDURE `securich`.`drop_user`( usernamein varchar(16), hostnamein varchar(60) )
  BEGIN
  
    DECLARE userexists int;

    DECLARE mybigversion VARCHAR(10);
    DECLARE mymidversion INT(10);
    DECLARE mysmallversion VARCHAR(10);
    
    
    SET userexists = (
       select count(*)
       from sec_us_ho usho join (
          select ID
          from sec_users
          where USERNAME=usernamein
          ) us join (
          select ID
          from sec_hosts
          where HOSTNAME=hostnamein
          ) ho
       where us.ID=usho.US_ID and
       ho.ID=usho.HO_ID
       );


    IF ( select count(*) from sec_users where USERNAME=usernamein) = 0 THEN

       select "Username supplied is incorrect or does not exist";

    ELSEIF (select count(*) from sec_hosts where HOSTNAME=hostnamein) = 0 THEN

       select "Hostname supplied is incorrect or does not exist";

    ELSEIF userexists = 0 THEN

       select "USER DOES NOT EXIST";

    ELSE

		SET @USID = (select ID from sec_users where USERNAME=usernamein);
		SET @HOID = (select ID from sec_hosts where HOSTNAME=hostnamein);
		SET @USHOID = (select ID from sec_us_ho where US_ID=@USID and HO_ID=@HOID);
		
		delete from sec_users where ID=@USID;
		delete from sec_us_ho where ID=@USHOID;
		delete from sec_us_ho_profile where US_HO_ID=@USHOID;
		delete from sec_us_ho_db_sp where US_ID=@USID and HO_ID=@HOID;
		delete from sec_us_ho_db_tb where US_ID=@USID and HO_ID=@HOID;
		
		call reconciliation('sync');  /* Run reconciliation in order to audit the revokes of privileges! */

		SET @d = CONCAT('drop user "', usernamein , '"@"' , hostnamein , '"'); /* Drop since the user doesn't have any privileges at all! */

	    PREPARE dropcom FROM @d;
		EXECUTE dropcom;
		
        SET @g = CONCAT('User "', usernamein , '"@"' , hostnamein , '" completely dropped from securich');
		
		SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
        SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
        INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());
        
	    SET @mybigversion = (SELECT SUBSTRING_INDEX(@version, '.', 1));
	    SET @mymidversion = (SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(@version, '.', 2),'.',-1));
        SET @mysmallversion = (SELECT left(SUBSTRING_INDEX(SUBSTRING_INDEX(@version, '.', 3),'.',-1),3));

  	    IF (@mysmallversion RLIKE '[[:lower:]]') || (@mysmallversion  RLIKE '[[:punct:]]') THEN
           set @mysmallversion=(select left(@mysmallversion,2));
           IF (@mysmallversion RLIKE '[[:lower:]]') || (@mysmallversion  RLIKE '[[:punct:]]') THEN
              set @mysmallversion=(select left(@mysmallversion,1));
           END IF;
        END IF; 
           
        /* If mysql version is 5.1.7 or above then processlist view is available on information_schema */

        IF (( mybigversion > '4' AND mymidversion > 0 AND mysmallversion > 6  ) or ( mybigversion > '4' AND mymidversion > 1 )) THEN

          SET @CNT = (
             select count(*)
             from information_schema.processlist
             where USER=usernamein and
             HOST like CONCAT(hostnamein ,'%')
             );

          SET @VAR=1;

          WHILE ( @VAR <= @CNT) DO

              SET @TID = (
                 select id
                 from information_schema.processlist
                 where USER=usernamein and
                 HOST like CONCAT(hostnamein ,'%') limit 1
                 );

              SET @k = CONCAT('kill ' , @TID);
              PREPARE killcom FROM @k;
              EXECUTE killcom;
              set @k=NULL;

              SET @VAR=@VAR+1;

          END WHILE;
          
          IF ((hostnamein='127.0.0.1') or (hostnamein='localhost')) THEN
            
             IF hostnamein='127.0.0.1' then
                set hostnamein='localhost';
             ELSEIF hostnamein='localhost' then
                set hostnamein='127.0.0.1';             
             END IF;

             SET @CNT = (
                select count(*)
                from information_schema.processlist
                where USER=usernamein and
                HOST like CONCAT(hostnamein ,'%')
             );
   
             SET @VAR=1;
   
             WHILE ( @VAR <= @CNT) DO
   
                SET @TID = (
                   select id
                   from information_schema.processlist
                   where USER=usernamein and
                   HOST like CONCAT(hostnamein ,'%') limit 1
                );
   
                SET @k = CONCAT('kill ' , @TID);
                PREPARE killcom FROM @k;
                EXECUTE killcom;
                set @k=NULL;
   
                SET @VAR=@VAR+1;

             END WHILE;
          
          END IF;

       END IF;

    END IF;  
    
  END$$

DELIMITER ;
