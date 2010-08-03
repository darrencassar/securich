ALTER TABLE `securich`.`sec_config` CHANGE COLUMN `VALUE` `VALUE` VARCHAR(40) NULL  ;
insert into sec_config (PROPERTY,VALUE) values ('mode','strict');
insert into sec_config (PROPERTY,VALUE) values ('admin_user',(select substring_index(user(),'@',1)));
