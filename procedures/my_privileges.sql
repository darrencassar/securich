#######################################################################################
##                                                                                   ##
##   This is my_privileges, a script used to show users their privileges on a        ##
##   particular database or on all databases / objects they request                  ##
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

DROP PROCEDURE IF EXISTS my_privileges;

DELIMITER $$


CREATE PROCEDURE `securich`.`my_privileges`( dbnamein varchar(64))
  BEGIN

      DECLARE un varchar(16);
      DECLARE hn varchar(60);
      DECLARE tors int;

      set un=(select (substring_index(user(),'@',1)));
      set hn=(select (substring_index(user(),'@',-1)));
      
      /*IF it's a tcp session it could still be showing as localhost due to dns but the following resolves the problem*/
      set tors=(select count(HOST) from information_schema.processlist where ID=(select connection_id()) and HOST like '%:%');
      
      IF dbnamein = '' THEN
         call show_full_user_entries(un);
      ELSE
         IF hn = 'localhost' && tors = '1' THEN
            call show_user_privileges(un,'127.0.0.1',dbnamein,'all');
         ELSE
            call show_user_privileges(un,hn,dbnamein,'all');
         END IF;
      END IF;

END$$

DELIMITER ;