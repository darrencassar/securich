create table sec_configuration
  ( conf_param varchar(40),
    conf_value varchar(40)
  ) engine=myisam;

insert into sec_configuration values ('mode','strict');
