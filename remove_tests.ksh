 for dir in `find . -type d -name test_results` ; do
       cd $dir
	anz=`ls | wc -l`
	echo $anz
	let anz=$anz-1 
	echo $anz
	if [ $anz -gt 1 ] ; then
          for dir2 in `ls -t | head -$anz` ;  do
	      echo $dir2
	  done
	fi
	cd $SCENARIOS
done
