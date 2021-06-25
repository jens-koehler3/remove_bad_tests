#! /bin/ksh

for dir in $(find . -type d -name test_results -exec sed -E 's/\.\\///gm;t;d' +) ; do
	echo "$dir" >> "scan_rm_datei"
		#scanfile=scan_rm_datei
	#for dir in $(egrep -e "./" $scanfile)
	#do
	#	dir=$SCENARIOS"/"$dir
	#	echo $dir >> pfad_rm_datei
	#done
	#cd $dir
	#anz=`ls | wc -l`
	#echo $anz
	#let anz=$anz-1 
	#echo $anz
	#if [ $anz -gt 1 ] ; then
		#for dir2 in `ls -t | head -$anz` ;  do
			#echo $dir2
		#done
	#fi
	#cd $SCENARIOS

done
