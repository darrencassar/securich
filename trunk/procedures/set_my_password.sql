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

DROP PROCEDURE IF EXISTS set_my_password;

DELIMITER $$

CREATE PROCEDURE `securich`.`set_my_password`(oldpasswordin VARCHAR(50), newpasswordin VARCHAR(50))
SQL SECURITY INVOKER
  BEGIN
    
    DECLARE un varchar(16);
    DECLARE hn varchar(60);
#    DECLARE tors int;

    set un=(select (substring_index(current_user(),'@',1)));
    set hn=(select (substring_index(current_user(),'@',-1)));

    
    /*IF it's a tcp session it could still be showing as localhost due to dns but the following resolves the problem*/
#    SET tors=(select COUNT(HOST) from information_schema.processlist WHERE ID=(SELECT connection_id()) AND HOST LIKE '%:%');

     SET @call = CONCAT('call set_password ("' , un , '","' , hn , '","' , oldpasswordin , '","' , newpasswordin , '");');
     PREPARE callsetpassword FROM @call;
     EXECUTE callsetpassword;
       
  END$$

DELIMITER ;
