update sec_privileges set TYPE = 0 where PRIVILEGE='TRIGGER';
update sec_privileges set TYPE = 0 where PRIVILEGE='CREATE VIEW';
update sec_privileges set TYPE = 0 where PRIVILEGE='SHOW VIEW';

INSERT INTO `sec_roles` VALUES (3,execute);
INSERT INTO `sec_ro_pr` VALUES (6,3,17);