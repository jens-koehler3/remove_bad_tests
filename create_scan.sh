#!/usr/bin/ksh

#datei=$1

if [ "$1" = "" ] ; then
  USAGE="Bitte rufen sie das Skript $0 folgendermaﬂen auf:\n$0 <Paketnummer>\n"
    echo $USAGE
  exit
fi

#rm $TMP/scan*
rm doit_$1.sh

touch doit_$1.sh
echo "export PROTO_TAG=_PSM_$1_FINAL" >> doit_$1.sh
echo "nohup watchDog -m scan -S scan_$1 &" >> doit_$1.sh

chmod 755 doit_$1.sh

cd /ccb/ccb20b/sharereg/TL/szenarios_batch/pack$1

rm scan*

#pwd

ls | grep CU > scan_test

#cp scan_test /ccb/ccb20b/sharereg/TL/szenarios_batch

datei=scan_test

touch scan_$1
echo "create_xrefs" >> scan_$1

while read  auftrag; do
#  touch scan_$1_neu
#  echo "scan_xrefs" >> scan_$1
   echo "pack$1/$auftrag" >> scan_$1
done < $datei

cp scan_$1 /ccb/ccb20b/sharereg/TL/szenarios_batch
