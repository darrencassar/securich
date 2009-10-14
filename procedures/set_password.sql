#######################################################################################
##                                                                                   ##
##   This is set_password, a script used to update users' passwords.                 ##
##                                                                                   ##
##   This program was originally sponsored by TradingScreen Inc                      ##
##   Information about TS is found at www.tradingscreen.com                          ##
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

DROP PROCEDURE IF EXISTS set_password;

DELIMITER $$

CREATE PROCEDURE `securich`.`set_password`( usernamein varchar(50), hostnamein varchar(50), oldpasswordin varchar(50), newpasswordin varchar(50))
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
    DECLARE ROOTUSER INT;


    SET CORRECTUSER= (select CONCAT(usernamein,'@',hostnamein)=user());
    SET PASSWORDLENGTH= (select VALUE from sec_config where PROPERTY='password_length);
    SET ROOTUSER= (select 'root'=(substring_index(user(),'@',1)));

     IF CORRECTUSER = 1 OR ROOTUSER = 1 THEN

        SET USHOID= (
           select ID
           from sec_us_ho usho
           where usho.US_ID= (
              select ID
              from sec_users
              where USERNAME=usernamein
              )
           and usho.HO_ID = (
              select ID
              from sec_hosts
              where HOSTNAME=hostnamein
              )
           );

        SET PASSW0 = (
           select pw0
           from sec_us_ho_profile
           where US_HO_ID = USHOID );

        IF (select PASSWORD(oldpasswordin)) <> PASSW0 and ROOTUSER <> 1 THEN

           select "Invalid original password, please check your own password and try again!";

           select sleep(5); /* If the password is not guessed this sleep takes place. It is there to hinder a brute force attack!*/

        ELSEIF ((select newpasswordin REGEXP "[[[:alpha:]+][[:digit:]+][[:punct:]+]|[[:alpha:]+][[:punct:]+][[:digit:]+]|[[:punct:]+][[:alpha:]+][[:digit:]+]|[[:punct:]+][[:digit:]+][[:alpha:]+]|[[:digit:]+][[:alpha:]+][[:punct:]+]|[[:digit:]+][[:punct:]+][[:alpha:]+]]") = 0 OR (select length(newpasswordin)) < PASSWORDLENGTH ) and ROOTUSER <> 1 /*newpasswordin = ''*/ THEN

           select CONCAT("Invalid password - Password must be at least " , PASSWORDLENGTH , " characters long and include at least a number, a character and one of the following   !\"$%^&*()-_=+[]{}\'@;:#~,.<>/\?|");

        ELSE

           SET LASTUPDATE = (select ID from sec_us_ho_profile where US_HO_ID=USHOID and UPDATE_TIMESTAMP > ADDDATE(NOW(), INTERVAL -24 HOUR));

           IF LASTUPDATE IS NULL THEN

              update sec_us_ho_profile
              set UPDATE_COUNT = '0'
              where US_HO_ID=USHOID;

           END IF;


           SET UPDATECOUNT = (select UPDATE_COUNT from sec_us_ho_profile where US_HO_ID=USHOID and UPDATE_TIMESTAMP > ADDDATE(NOW(), INTERVAL -24 HOUR));

           IF UPDATECOUNT < 1 OR UPDATECOUNT IS NULL THEN

              SET @sp = CONCAT('set password for "' , usernamein , '"@"' , hostnamein , '" = PASSWORD ("' , newpasswordin , '")');

              PREPARE setpassword FROM @sp;
              EXECUTE setpassword;

              SET PASSW1 = (
                 select pw1
                 from sec_us_ho_profile
                 where US_HO_ID = USHOID );

              SET PASSW2 = (
                 select pw2
                 from sec_us_ho_profile
                 where US_HO_ID = USHOID );

              SET PASSW3 = (
                 select pw3
                 from sec_us_ho_profile
                 where US_HO_ID = USHOID );

              SET PASSW4 = (
                 select pw4
                 from sec_us_ho_profile
                 where US_HO_ID = USHOID );


              update sec_us_ho_profile
              set PW4 = PASSW3,
                  PW3 = PASSW2,
                  PW2 = PASSW1,
                  PW1 = PASSW0,
                  PW0 = PASSWORD(newpasswordin),
                  UPDATE_TIMESTAMP=now(),
                  UPDATE_COUNT = UPDATE_COUNT + 1
              where US_HO_ID=USHOID;

           ELSEIF UPDATECOUNT > 10 THEN

              select "PASSWORD CHANGE FOR THIS USER HAS EXCEEDED LIMIT - Try in 24hrs";

           ELSE

              SET @sp = CONCAT('set password for "' , usernamein , '"@"' , hostnamein , '" = PASSWORD ("' , newpasswordin , '")');

              PREPARE setpassword FROM @sp;
              EXECUTE setpassword;

              update sec_us_ho_profile
              set PW0 = PASSWORD(newpasswordin),
                  UPDATE_COUNT = UPDATE_COUNT + 1
              where US_HO_ID=USHOID;
           END IF;

        END IF;

     ELSE

        select "YOU DO NOT HAVE PERMISSION TO CHANGE THE PASSWORD FOR THE USER SPECIFIED!";

     END IF;

  END$$

DELIMITER ;
