#!/usr/bin/ksh



datei=$1 
check=0
fehler=0
b=0

if [ "$1" = "" ] ; then
  USAGE="Bitte rufen sie das Skript $0 folgendermassen auf:\n$0 <Eingabedatei>\n<Eingabedatei>-Format:\ndatum_1(DD.MM.YYYY) zeit_1(HH24:MI:SS) datum_2 zeit_2 preis(z.B. 0.0076) flag(F/O)\n"
  echo $USAGE
  exit 
fi

rm $TMP/cbc_*

while read  datum_1 zeit_1 datum_2 zeit_2 preis flag ; do
if [ $flag = "F" ] ; then
   flag=\'Z0003\',\'Z0056\'
else
   flag=\'Z0001\'
fi



a=`sqlplus -s ${ONL_USER}/${ONL_PASSWORD}@${ONL} << EOF
    set heading off;
    set feedback off;
   select count(*) from rated_usage_event_dtag;
   commit;
   exit
EOF`


sqlplus -s ${ONL_USER}/${ONL_PASSWORD}@${ONL} << EOF
   set heading off;
   set feedback off;
   alter session set nls_date_format = 'DD.MM.YYYY HH24:MI:SS';
   select distinct gross_billable_charge, rating_distance_zone_code, usage_start_date_time from rated_usage_event_dtag where rating_distance_zone_code in ( $flag ) and gross_billable_charge <> '$preis' and usage_start_date_time between TO_DATE('$datum_1 $zeit_1','DD.MM.YYYY HH24:MI:SS') and TO_DATE('$datum_2 $zeit_2','DD.MM.YYYY HH24:MI:SS');
   commit;
   exit
EOF

#Anzahl Fehler
count2=`sqlplus -s ${ONL_USER}/${ONL_PASSWORD}@${ONL} << EOF
   set heading off;
   set feedback off;
   alter session set nls_date_format = 'DD.MM.YYYY HH24:MI:SS';
   select count(*) from rated_usage_event_dtag where rating_distance_zone_code in ( $flag ) and gross_billable_charge <> '$preis' and usage_start_date_time between TO_DATE('$datum_1 $zeit_1','DD.MM.YYYY HH24:MI:SS') and TO_DATE('$datum_2 $zeit_2','DD.MM.YYYY HH24:MI:SS');
   commit;
   exit
EOF`

if [ $count2 != 0 ] ; then
  zone=$flag
  daten=$datum_1
  zeit1=$zeit_1
  zeit2=$zeit_2
  touch $TMP/cbc_$$
  echo $count2 $zone $daten $zeit1 $zeit2 >> $TMP/cbc_$$
fi

#Anzahl verarbeitete CDRs
count=`sqlplus -s ${ONL_USER}/${ONL_PASSWORD}@${ONL} << EOF
   set heading off;
   set feedback off;
   alter session set nls_date_format = 'DD.MM.YYYY HH24:MI:SS';
   select count(*)  from rated_usage_event_dtag where rating_distance_zone_code in ( $flag ) and usage_start_date_time between TO_DATE('$datum_1 $zeit_1','DD.MM.YYYY HH24:MI:SS') and TO_DATE('$datum_2 $zeit_2','DD.MM.YYYY HH24:MI:SS');
   commit;
   exit
EOF`

echo "Tarifzone      :   $flag"
echo "Zeitraum       :   $datum_1 $zeit_1 - $datum_2 $zeit_2"
echo "Aktuelle Anzahl:   $count"
echo "Fehler         :   $count2\n\n"
#let check=${check}+${count}
check=`expr $check + $count`
fehler=`expr $fehler + $count2`

#echo $a
#    echo "ANFANG $datum_1 $zeit_1\n " 
#    echo "ENDE   $datum_2 $zeit_2\n "
done < $datei;

#echo $a
#echo $check

if [ $a = $check ] ; then
   echo "Anzahl der geprueften CDRs stimmen ueberein!"
else
   echo "Anzahl der geprueften CDRs stimmt nicht ueberein!"
fi

if [ $fehler != 0 ] ; then
#   cat $TMP/cbc_$$
   while read fehler zone daten zeit1 zeit2 ; do  
    echo "$fehler Preise fuer den/die Zonencode/s $zone, am $daten,von $zeit1 bis $zeit2, sind nicht korrekt!"
   done < $TMP/cbc_$$
   rm $TMP/cbc_$$
else
   echo "Keine Fehler im Preis!"
fi
