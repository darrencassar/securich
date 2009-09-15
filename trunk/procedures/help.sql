#######################################################################################
##                                                                                   ##
##   This is help, a script used to display documentation for each stored procedure. ##
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

DROP PROCEDURE IF EXISTS help;

DELIMITER $$

CREATE PROCEDURE `securich`.`help`( storedprocedurenamein varchar(255) )
  BEGIN

    DECLARE storedprocedurexists int;

    SET storedprocedurexists = (
       select count(*)
       from sec_help
       where STOREDPROCEDURE = storedprocedurenamein
       );

    IF (storedprocedurexists = 0) AND (select length(storedprocedurenamein)) <> 0 THEN

       select "Stored procedure requested does not exist or does not have a `help` entry";

    ELSE

       IF (select length(storedprocedurenamein) = 0) THEN

          select DESCRIPTION from sec_help where ID='1';

          select distinct STOREDPROCEDURE
          from sec_help
          where STOREDPROCEDURE <> ''
          order by ID asc;

       ELSE

          select DESCRIPTION from sec_help where STOREDPROCEDURE = storedprocedurenamein;

       END IF;

    END IF;

END$$

DELIMITER ;