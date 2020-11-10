#!/bin/bash
#
#  conpress
#  tar -czvf ciscat-full-bundle-latest-with-linux-jre.tar.gz cis-cat-full
#  
#  extract
#  tar -xvf ciscat-full-bundle-latest-with-linux-jre.tar.gz
#
#  upload
#  curl -v -u admin:admin123 --upload-file $ciscatzip https://slitrepo.it.slb.com:8443/repository/raw-slit/ciscat/linux/$ciscatzip
#
# this script created so you can run ciscat evaluation and place results in /root 
# will create .html and txt files for ocal and xccdf evaluations


# --------------------- FUNCTION --------------------------
# NAME: logit()
# DESCRIPTION: logs the message to log file for stacktrace
# GLOBAL: LOGFILE
# ----------------------------------------------------------
logit() {
  
  # local variable to function
  local now
   __date=$(date +%Y%m%d.%H%M%S)

   echo "${__date} $@" >> $LOGFILE
   echo "CISCAT EVAL ${__date} $@"
}

# =================================================================
# ====================== SCRIPTION EXECUTION ======================
# =================================================================

# Global variables for ciscat evalution
LOGFILE='/tmp/CisCatEval.log'
CISCAT_ARCHIVE='ciscat_bundle_latest.tar.gz'
CISCAT_ROOT='/opt/ciscat_latest'
DOWNLOAD_DIR="/opt/ciscat_eval"

logit "Starting ciscateveal.sh Script"

if ( ! [ -f "${DOWNLOAD_DIR}/CIS-CAT.sh" ] ); then

  logit "ERROR: Failed to find folder /opt/cis-cat-full/CIS-CAT.sh, Trying to download and decompress"
  logit "Downloading usaing, curl -k https://slitrepo.it.slb.com:8443/repository/raw-slit/ciscat/linux/$ciscatzip -o /opt/$ciscatzip"
  curl -k https://slitrepo.it.slb.com:8443/repository/raw-slit/ciscat/linux/$ciscatzip -o /opt/$ciscatzip
  logit "confirming $catcatzip download"
  cd /opt
  if [ ! $(find . -name $ciscatzip) ]; then 
    logit "ERROR: Could not find /opt/$ciscatzip , download failed, Cannot continue"
    #setting variable ciscateval to false makes ciscat skip evaluation section
    ciscateval=false
    exit -1
  fi
#  logit "Installing package unzip"
#  yum -y install unzip 
  # removed vjava, now integrated with zip
  #yum -y install unzip java-1.8.0-openjdk
  logit "Decompressing $ciscatzip"
#  unzip -o $ciscatzip
  cd /opt
  tar -xvf $ciscatzip
  logit "Check if file unzipped properly, $ciscatroot"
  if ( ! [ -a $ciscatroot ]); then 
    logit "ERROR: Failed to find folder $ciscatroot, Cannot continue"
    exit -1
  fi
  chmod a+x /opt/cis-cat-full/jre/bin/*
fi
logit "check on java"
#if (! type -p java);then 
if ( ! [ -f $ciscatroot/jre/bin/java ] ); then 
   logit "ERROR: jre mising from $ciscatroot/jre/bin/java , please check install or contact SaltStack administrators, exiting" 
   exit -1
fi   
cd $ciscatroot
# WE are now swithing to auto choose on the benchmarks
# 
<< 'MULTILINE-COMMENT'
if  (cat /etc/redhat-release | grep 'Red Hat Enterprise Linux Server release 7'); then
  benchmark="CIS_Red_Hat_Enterprise_Linux_7_Benchmark"
elif (cat /etc/redhat-release | grep 'Red Hat Enterprise Linux Server release 6'); then
   benchmark="CIS_Red_Hat_Enterprise_Linux_6_Benchmark"
elif (cat /etc/redhat-release | grep 'CentOS Linux release 7'); then
  benchmark="CIS_CentOS_Linux_7_Benchmark"
elif (cat /etc/redhat-release | grep 'CentOS release 6'); then
  benchmark="CIS_CentOS_Linux_6_Benchmark"
else
  logit  "ERROR: no supported OS Found, exiting script"
  benchmark="none"
  exit -1
fi
benchmarkfile=$(find $ciscatroot/benchmarks/ -name "$benchmark*xccdf.xml")
MULTILINE-COMMENT

logit "Running benchmark $benchmarkfile"
cd $ciscatroot
bash CIS-CAT.sh -a -aa -s --report-txt --oval-results --report-xml -r /root
logit "Finished ciscateveal.sh Script"
