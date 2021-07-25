#!/usr/bin/sh

paket = `$(psm_package.pl -modus SHOW|grep -v "^$"|tail -n 1|cut -d_ -f3)`
echo ${paket}
#echo "Hello world!" 
