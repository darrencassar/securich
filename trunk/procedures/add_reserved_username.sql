#######################################################################################
##                                                                                   ##
##   This is add_reserved_username, a script used to add usernames to the list of    ##
##   reserved usernames.                                                             ##
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

use securich;

DROP PROCEDURE IF EXISTS add_reserved_username;

DELIMITER $$

CREATE PROCEDURE `securich`.`add_reserved_username`( usernamein varchar(16))
  BEGIN
     
     DECLARE NOU INT; /* number of usernames */
     DECLARE NOS INT; /* number of spaces */
     
     SET NOU = (SELECT COUNT(*) FROM sec_reserved_usernames WHERE USERNAME=usernamein);
     SET NOS =  (SELECT LENGTH(usernamein) - LENGTH(REPLACE(usernamein, ' ', '')));
          
     IF NOU= 0 && NOS = 0 THEN
           insert into sec_reserved_usernames (USERNAME) values (usernamein);
     ELSE
        IF NOS > 0 THEN
           select "Username can't contain spaces" as ERROR;
        END IF;
     END IF;
     
  END$$

DELIMITER ;