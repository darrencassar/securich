update sec_privileges set TYPE = 0 where PRIVILEGE='TRIGGER';
update sec_privileges set TYPE = 0 where PRIVILEGE='CREATE VIEW';
update sec_privileges set TYPE = 0 where PRIVILEGE='SHOW VIEW';