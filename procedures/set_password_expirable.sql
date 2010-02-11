#######################################################################################
##                                                                                   ##
##   This is set_password, a script used to update users' password expiry setting.   ##
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

DROP PROCEDURE IF EXISTS set_password_expirable;

DELIMITER $$

CREATE PROCEDURE `securich`.`set_password_expirable`(usernamein VARCHAR(50), passwordexpirable CHAR(1))
  BEGIN
  
    IF (SELECT COUNT(*) FROM sec_users WHERE USERNAME=usernamein) = 1 THEN
       IF passwordexpirable = 'Y' or passwordexpirable='y' or passwordexpirable = 'N' or passwordexpirable='n' THEN
          update sec_users set PASS_EXPIRABLE=setting where USERNAME=usernamein;
       ELSE
          select "Setting specified can't be used ... please set to either Y or N" as ERROR;
       END IF;
    ELSE
       select "User does not exist" as ERROR;
    END IF;
       
  END$$

DELIMITER ;