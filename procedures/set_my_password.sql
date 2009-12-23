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

CREATE PROCEDURE `securich`.`set_my_password`(oldpasswordin VARCHAR(50), newpasswordin VARCHAR(50))
  BEGIN
    
    select @username=(select substring_index(user(),'@',1));
    select @hostname=(select substring_index(user(),'@',-1));
   
    call set_password(@username,@hostname,oldpasswordin,newpasswordin);
    
  END$$

DELIMITER ;
