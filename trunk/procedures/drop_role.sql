#######################################################################################
##                                                                                   ##
##   This is drop_role, a script used to drop a role                                 ##
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

DROP PROCEDURE IF EXISTS drop_role;

DELIMITER $$

CREATE PROCEDURE `securich`.`drop_role`(rolenamein varchar(64))
  BEGIN

     DECLARE ROLE_ID INT;
     DECLARE ro_inuse_sp INT;
     DECLARE ro_inuse_tb INT;
     DECLARE ro_inuse INT;
     
     SET ro_inuse_sp = (
        select count(*) 
        from sec_us_ho_db_sp_ro join (
           select ID 
           from sec_roles 
           where ROLE=rolenamein
           ) ro 
        where sec_us_ho_db_sp_ro.RO_ID=ro.ID);
       
     SET ro_inuse_tb = (
        select count(*) 
        from sec_us_ho_db_tb_ro join (
           select ID 
           from sec_roles 
           where ROLE=rolenamein
           ) ro 
        where sec_us_ho_db_tb_ro.RO_ID=ro.ID);


     SET ro_inuse = ro_inuse_sp + ro_inuse_tb;
     
     IF (select count(*) from sec_roles where ROLE=rolenamein) < 1 THEN
        select "Role does not exist" as ERROR;
     ELSEIF ro_inuse > 0 THEN
        select "Role is currently in use and therefore can not be deleted" as ERROR;
     ELSE
        delete from sec_roles where ROLE=rolenamein;
     END IF;

  END$$

DELIMITER ;