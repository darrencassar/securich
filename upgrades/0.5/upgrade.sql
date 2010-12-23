INSERT INTO `sec_config` (`PROPERTY`,`VALUE`) VALUES ('priv_mode','safe');
UPDATE `sec_config` set PROPERTY='mysql_to_securich_reconciliation_in_progress' where PROPERTY='reverse_reconciliation_in_progress';
UPDATE `sec_config` set PROPERTY='sec_mode' and VALUE=0 where PROPERTY='mode';
