#######################################################################################
##                                                                                   ##
##   This is set_password, a script used to update users' passwords.                 ##
##                                                                                   ##
##   This program was originally sponsored by TradingScreen Inc                      ##
##   Information about TS is found at www.tradingscreen.com                          ##
##                                                                                   ##
##   This program was written by Darren Cassar 2009.                                 ##
##   Password checks code inspired by Mark Leith                                     ##
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

DROP PROCEDURE IF EXISTS set_password;

DELIMITER $$

CREATE PROCEDURE `securich`.`set_password`( usernamein VARCHAR(50), hostnamein VARCHAR(50), oldpasswordin VARCHAR(50), newpasswordin VARCHAR(50))
  BEGIN

    DECLARE PASSW0 CHAR(41);
    DECLARE PASSW1 CHAR(41);
    DECLARE PASSW2 CHAR(41);
    DECLARE PASSW3 CHAR(41);
    DECLARE PASSW4 CHAR(41);
    DECLARE PASSWORDLENGTH INT;
    DECLARE USHOID INT;
    DECLARE UPDATECOUNT INT;
    DECLARE LASTUPDATE INT;
    DECLARE CORRECTUSER INT;
    DECLARE SUPERUSER VARCHAR(16);
    DECLARE ADMINUSER VARCHAR(16);
    DECLARE message VARCHAR(256);
    DECLARE countdict INT;
    DECLARE tors int;
    
    /*IF it's a tcp session it could still be showing as localhost due to dns but the following resolves the problem*/
    set tors=(select count(HOST) from information_schema.processlist where ID=(select connection_id()) and HOST like '%:%');
     
    /*IF hostnamein='127.0.0.1' && tors='1' then
        SET CORRECTUSER= ('1');

    ELSE
        SET CORRECTUSER=(SELECT (SUBSTRING_INDEX(USER(),'@',1))=usernamein);
    END IF;*/
    
    SET CORRECTUSER=(SELECT (SUBSTRING_INDEX(USER(),'@',1))=usernamein);

    SET PASSWORDLENGTH= (SELECT VALUE FROM sec_config WHERE PROPERTY='password_length');
    SET SUPERUSER= (SELECT (SUBSTRING_INDEX(USER(),'@',1)));
    SET ADMINUSER= (SELECT VALUE FROM sec_config WHERE PROPERTY='admin_user');

     IF CORRECTUSER = 1 OR SUPERUSER = 'root' OR SUPERUSER = ADMINUSER THEN

        SET USHOID= (
           SELECT ID
           FROM sec_us_ho usho
           WHERE usho.US_ID= (
              SELECT ID
              FROM sec_users
              WHERE USERNAME=usernamein
              )
           AND usho.HO_ID = (
              SELECT ID
              FROM sec_hosts
              WHERE HOSTNAME=hostnamein
              )
           );

        SET PASSW0 = (
           SELECT pw0
           FROM sec_us_ho_profile
           WHERE US_HO_ID = USHOID );

        IF (SELECT PASSWORD(oldpasswordin)) <> PASSW0 AND ( SUPERUSER <> 'root' OR SUPERUSER <> ADMINUSER ) THEN

           SET message = "Invalid original password, please check your own password and try again!";

           SELECT SLEEP(5); /* If the password is not guessed this sleep takes place. It is there to hinder a brute force attack!*/

        ELSEIF ( SUPERUSER <> 'root' AND SUPERUSER <> ADMINUSER ) THEN
                
           -- check the password length  
           IF ((SELECT LENGTH(newpasswordin)) < PASSWORDLENGTH) AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_length_check') = '1') THEN
              SET message = CONCAT("Password should be at least " , PASSWORDLENGTH , " characters long");
           END IF;
           
           -- check whether the password is too simple by comparing it against
           -- a table that holds a dictionary of simple words (admin.dict)
           SELECT COUNT(*) INTO countdict FROM sec_dictionary WHERE WORD = newpasswordin;
           
           IF (countdict > 0) AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_dictionary_check') = '1') THEN
             SET message = CONCAT_WS(',',message,' Password too simple');
           END IF;
           
           -- check for a lower case character  
           IF (newpasswordin NOT RLIKE '[[:lower:]]') AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_lowercase_check') = '1') THEN
              SET message = CONCAT_WS(',',message,
                                    ' Password should contain lower case character');
           END IF;
           
           -- check for an upper case character  
           IF (newpasswordin NOT RLIKE '[[:upper:]]') AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_uppercase_check') = '1') THEN
              SET message = CONCAT_WS(',',message,
                                     ' Password should contain upper case character');
           END IF;
           
           -- check for a digit  
           IF (newpasswordin NOT RLIKE '[[:digit:]]') AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_number_check') = '1') THEN
              SET message = CONCAT_WS(',',message,
                                     ' Password should contain a digit');
           END IF;
           
           -- check for punctuation  
           IF (newpasswordin NOT RLIKE '[[:punct:]]') AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_special_character_check') = '1') THEN
              SET message = CONCAT_WS(',',message,
                                      ' Password should contain punctuation');
           END IF;
           
           -- lastly check whether username and password are the same 
           -- if it is, admonish!
           IF (usernamein = newpasswordin) AND ((SELECT VALUE FROM sec_config WHERE PROPERTY='password_username_check') = '1') THEN
              SET message = 'Username and password are the same!';
           END IF;
           
        END IF;
        
        -- if message is still NULL then password is OK
        IF message IS NOT NULL THEN
           SELECT message;      
        ELSE
        
           SET LASTUPDATE = (SELECT ID FROM sec_us_ho_profile WHERE US_HO_ID=USHOID AND UPDATE_TIMESTAMP > ADDDATE(NOW(), INTERVAL -24 HOUR));
        
           IF LASTUPDATE IS NULL THEN
        
              UPDATE sec_us_ho_profile
              SET UPDATE_COUNT = '0'
              WHERE US_HO_ID=USHOID;

           END IF;


           SET UPDATECOUNT = (SELECT UPDATE_COUNT FROM sec_us_ho_profile WHERE US_HO_ID=USHOID AND UPDATE_TIMESTAMP > ADDDATE(NOW(), INTERVAL -24 HOUR));

           IF UPDATECOUNT < 1 OR UPDATECOUNT IS NULL THEN

              SET @sp = CONCAT('set password for "' , usernamein , '"@"' , hostnamein , '" = PASSWORD ("' , newpasswordin , '")');

              PREPARE setpassword FROM @sp;
              EXECUTE setpassword;

              SET PASSW1 = (
                 SELECT pw1
                 FROM sec_us_ho_profile
                 WHERE US_HO_ID = USHOID );

              SET PASSW2 = (
                 SELECT pw2
                 FROM sec_us_ho_profile
                 WHERE US_HO_ID = USHOID );

              SET PASSW3 = (
                 SELECT pw3
                 FROM sec_us_ho_profile
                 WHERE US_HO_ID = USHOID );

              SET PASSW4 = (
                 SELECT pw4
                 FROM sec_us_ho_profile
                 WHERE US_HO_ID = USHOID );


              UPDATE sec_us_ho_profile
              SET PW4 = PASSW3,
                  PW3 = PASSW2,
                  PW2 = PASSW1,
                  PW1 = PASSW0,
                  PW0 = PASSWORD(newpasswordin),
                  UPDATE_TIMESTAMP=NOW(),
                  UPDATE_COUNT = UPDATE_COUNT + 1
              WHERE US_HO_ID=USHOID;

           ELSEIF UPDATECOUNT > 10 THEN

              SELECT "PASSWORD CHANGE FOR THIS USER HAS EXCEEDED LIMIT - Try in 24hrs";

           ELSE

              SET @sp = CONCAT('set password for "' , usernamein , '"@"' , hostnamein , '" = PASSWORD ("' , newpasswordin , '")');

              PREPARE setpassword FROM @sp;
              EXECUTE setpassword;

              UPDATE sec_us_ho_profile
              SET PW0 = PASSWORD(newpasswordin),
                  UPDATE_COUNT = UPDATE_COUNT + 1
              WHERE US_HO_ID=USHOID;
           END IF;

        END IF;

     ELSE

        SELECT "YOU DO NOT HAVE PERMISSION TO CHANGE THE PASSWORD FOR THE USER SPECIFIED!";

     END IF;

  END$$

DELIMITER ;
