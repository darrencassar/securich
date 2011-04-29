#######################################################################################
##                                                                                   ##
##   This is listcount, a script used to monitor securich installation progress.     ##
##                                                                                   ##
##   This program was written by Darren Cassar 2011.                                 ##
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

drop procedure if exists listcount;

delimiter $$

CREATE PROCEDURE listcount()
BEGIN
  set @reconlistcount = 10;

  WHILE @reconlistcount > 0 DO
    call reconciliation('listcount');
    select @reconlistcount into outfile '/tmp/sec_outfile';
    select sleep(2);
  END WHILE;
  
  select "0" into outfile '/tmp/sec_outfile';

END$$

DELIMITER ;
