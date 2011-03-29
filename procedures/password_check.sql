#######################################################################################
##                                                                                   ##
##   This is password_check, a script used to check for password discrepancies       ##
##   between securich and mysql.                                                     ##
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

DROP PROCEDURE IF EXISTS password_check;

DELIMITER $$


CREATE PROCEDURE `securich`.`password_check`()
  BEGIN

      DECLARE un VARCHAR(16);
      DECLARE hn VARCHAR(60);
      DECLARE pwm CHAR(41);
      DECLARE pws CHAR(41);
      DECLARE done INT DEFAULT 0;
      
      /* list of privileges a particular user entity (username@hostname) will be granted on a particular combination of database and tables */

      DECLARE cur_pass CURSOR FOR
      SELECT * FROM mysql_securich_users;
 
      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
         ROLLBACK;
         SELECT 'Error occurred - terminating - Securich to MySQL password reconciliation failed';
      END;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

      DROP TEMPORARY TABLE IF EXISTS mysql_securich_users;
      CREATE TEMPORARY TABLE mysql_securich_users AS
      SELECT mu.USER AS USERNAME,mu.HOST AS HOSTNAME,mu.PASSWORD AS "MySQL PW" ,sec.PW0 AS "SECURICH PW"
      FROM mysql.`user` mu JOIN (
           SELECT uhid.USERNAME, uhid.HOSTNAME, pr.PW0 
           FROM sec_us_ho_profile pr JOIN (
              SELECT uh.ID, us.USERNAME, ho.HOSTNAME 
              FROM sec_us_ho uh JOIN sec_users us JOIN sec_hosts ho
              WHERE uh.US_ID=us.ID AND 
              uh.HO_ID=ho.ID
              ) uhid
           WHERE pr.US_HO_ID = uhid.ID
           ) sec
         WHERE mu.PASSWORD <> sec.PW0 AND 
               mu.USER = sec.USERNAME AND
               mu.HOST = sec.HOSTNAME AND
         USER NOT IN (
            SELECT USERNAME 
            FROM sec_reserved_usernames)
         GROUP BY mu.USER;
       
      IF (SELECT COUNT(*) FROM  mysql_securich_users) > 0 THEN
      OPEN cur_pass;
      cur_pass_loop:WHILE(done=0) DO
      FETCH cur_pass INTO un, hn, pwm, pws;
      
          
      IF done=1 THEN
         LEAVE cur_pass_loop;
      END IF;
         UPDATE mysql.USER SET PASSWORD=pws WHERE USER=un AND HOST=hn;
         INSERT INTO aud_password (USERNAME,HOSTNAME,MPASS,SPASS,TIMESTAMP) VALUES (un,hn,pwm,pws,NOW());
         
      END WHILE cur_pass_loop;
      CLOSE cur_pass;
      FLUSH PRIVILEGES;
      END IF;
                                     
END$$

DELIMITER ;
