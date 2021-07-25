#!/bin/ksh

exchangeIniKeyValue()
{
  iniFile=$1
  parameter=$2
  val=$3

  if [ ! -f $iniFile ] ; then
      echo "WARNING Ini-File $iniFile not found. Therefore no exchange of $parameter $val"
      return
  fi

  [ "$parameter" = "" -o "$val" = "" ] && echo "ERROR exchangeIniKeyValue: parameter or value missing $iniFile $parameter $val" && exit 1

  egrep -q "^${parameter}=" $iniFile
  rc=$?

  if [ "$rc" = "0" ] ; then
    sed "s#^$parameter=.*#$parameter=$val#g" $iniFile > ${iniFile}.tmp
    mv ${iniFile}.tmp $iniFile
  elif [ "$rc" = "1" ] ; then
    echo "$parameter=$val" >> $iniFile
  else
    echo "ERROR egrep -q $parameter $iniFile failed"
    exit 1
  fi
}

readParameter()
{
  while getopts m: opt
  do
    case "$opt" in
      m) modus=$OPTARG ;;
      *) echo "Unknown Option $opt"
         exit 1 ;;
    esac
  done
  shift $(($OPTIND -1))
  [ $# -gt 0 ] && echo "Wrong number of parameters" && exit 1
}

new()
{
   cd $CONFIG/ini
   exchangeIniKeyValue CbmFormatter64s.ini ISIS_LOCATION /opt/isis/pdet3710
   exchangeIniKeyValue CbmFormatter64s.ini EXECUTABLE_NAME pdet3
   exchangeIniKeyValue CbmFormatter64s.ini REMOTE_HOST_NAME ukwts106
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_NUM 7
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_2 ISIS_KEY_MODE=ALL
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_3 ISIS_OMS_DOMAIN=192.57.138.68
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_4 ISIS_OMS_PORT=9091
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_5 ISIS_COMMON=/opt/isiscomm
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_6 SHLIB_PATH=/opt/isiscomm/t3/lib:/opt/isis/pdet3710 
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_7 ISIS_PCS_LOGDIR=/tmp/${ENVIRONMENT_LC} 

   exchangeIniKeyValue CbmRemoteFormatter64s.ini ISIS_LOCATION /opt/isis/pdet3710
   exchangeIniKeyValue CbmRemoteFormatter64s.ini EXECUTABLE_NAME pdet3
   exchangeIniKeyValue CbmRemoteFormatter64s.ini REMOTE_HOST_NAME ukwts106
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_NUM 7
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_2 ISIS_KEY_MODE=ALL
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_3 ISIS_OMS_DOMAIN=192.57.138.68
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_4 ISIS_OMS_PORT=9091
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_5 ISIS_COMMON=/opt/isiscomm
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_6 SHLIB_PATH=/opt/isiscomm/t3/lib:/opt/isis/pdet3710
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_7 ISIS_PCS_LOGDIR=/tmp/${ENVIRONMENT_LC} 
 
   exchangeIniKeyValue CbmBatchPapyrus64s.ini BP_ISIS_HOST ukwts106
   exchangeIniKeyValue CbmBatchPapyrus64s.ini BP_ISIS_CALL /opt/isis/pdet3710/pdet3
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_NUM 7
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_1 PROFILE=/
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_2 ISIS_KEY_MODE=ALL
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_3 ISIS_OMS_DOMAIN=192.57.138.68
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_4 ISIS_OMS_PORT=9091
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_5 ISIS_COMMON=/opt/isiscomm
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_6 SHLIB_PATH=/opt/isiscomm/t3/lib:/opt/isis/pdet3710 
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_7 ISIS_PCS_LOGDIR=/tmp/${ENVIRONMENT_LC} 

   ssh ${UNIX_USER}@ukwts106 mkdir -p /tmp/${ENVIRONMENT_LC}
}

old()
{
   cd $CONFIG/ini
   exchangeIniKeyValue CbmFormatter64s.ini ISIS_LOCATION /opt/isis/pdeh3600
   exchangeIniKeyValue CbmFormatter64s.ini EXECUTABLE_NAME pdeh
   exchangeIniKeyValue CbmFormatter64s.ini REMOTE_HOST_NAME pkgdext2
   exchangeIniKeyValue CbmFormatter64s.ini DOCEXEC_ENV_NUM 1
   
   exchangeIniKeyValue CbmRemoteFormatter64s.ini ISIS_LOCATION /opt/isis/pdeh3600
   exchangeIniKeyValue CbmRemoteFormatter64s.ini EXECUTABLE_NAME pdeh
   exchangeIniKeyValue CbmRemoteFormatter64s.ini REMOTE_HOST_NAME pkgdext2
   exchangeIniKeyValue CbmRemoteFormatter64s.ini DOCEXEC_ENV_NUM 1

   exchangeIniKeyValue CbmBatchPapyrus64s.ini BP_ISIS_HOST pkgdext2
   exchangeIniKeyValue CbmBatchPapyrus64s.ini BP_ISIS_CALL /opt/isis/pdeh3600/pdeh3
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_NUM 1
   exchangeIniKeyValue CbmBatchPapyrus64s.ini DOCEXEC_ENV_1 PROFILE=/
}

readParameter $*
case $modus in
  "new" ) new ;;
  "old" ) old ;;
  *     ) echo "Value of option -m [$modus] invalid. Only  new|old allowed."
          exit ;;
esac

echo "WARNING DFA files are not copied from remote host"
echo "!!!!!FINISHED!!!!!!"






  
