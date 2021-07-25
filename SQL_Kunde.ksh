#!/usr/bin/ksh

shrink.pl -modus CREATE_INSERT_SQL -source ccb20btg -target main_user,spassbad,ccb20btl -customerFile kunde_tg -add_hierarchy ALL -createSqlFile insert_1und1_kunde.sql -v
