#!/usr/bin/ksh

rm LOG2/*
shrink.pl -target main_user,spassbad,ccb20btl -modus CREATE_INSERT_SQL -CustomerFile kunde_tl -debug -addHierarchy all -createSqlFile customer_insert.sql
