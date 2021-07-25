#!/bin/sh

for i in `cat scan_372`
do
    for j in `ls -d $SCENARIOS/$i/test_control/run.2016*log 2>/dev/null`
   do
     echo $j
#     rm  -rf $j
   done 
done


