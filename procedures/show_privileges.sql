#######################################################################################
##                                                                                   ##
##   This is show privileges, a script used to find out what privileges are          ##
##   available to add to roles                                                       ##
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

DROP PROCEDURE IF EXISTS show_privileges;

DELIMITER $$

CREATE PROCEDURE `securich`.`show_privileges`()
  BEGIN

    drop table if exists sec_tmp_privileges;
    create temporary table sec_tmp_privileges select * from sec_privileges;
    alter table sec_tmp_privileges add column TYPE_OF_PRIV varchar(255);
    update sec_tmp_privileges set TYPE_OF_PRIV = 'Column Level' where TYPE=-1;
    update sec_tmp_privileges set TYPE_OF_PRIV = 'Table Level' where TYPE=0;
    update sec_tmp_privileges set TYPE_OF_PRIV = 'Stored Procedure Level' where TYPE=1;
    update sec_tmp_privileges set TYPE_OF_PRIV = 'Database Level' where TYPE=2;
    update sec_tmp_privileges set TYPE_OF_PRIV = 'Administration Level' where TYPE=3;
    select PRIVILEGE, TYPE_OF_PRIV from sec_tmp_privileges order by TYPE asc;

  END$$

DELIMITER ;