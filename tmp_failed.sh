#!/bin/sh

for i in `cat scan_all`
do
   for j in `ls -d $SCENARIOS/$i/test_results/* |  grep "failed"   2>/dev/null`
   do
     echo $j
#     rm  -rf $j
   done 
done


