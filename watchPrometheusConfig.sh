#!/bin/bash

INTERVAL=60 #seconds

while true; do

  TEMPDIR=`mktemp -d`
  cd ${TEMPDIR}

  # パーツファイルDL
  aws s3 sync ${PROMs3URL} ./

  echo "-- downloaded files --"
  ls ${TEMPDIR}

  # ------ prometheus.yml 確認 ------ #
  # パーツ組み立て
  ${PROMmergeScriptPath} ${TEMPDIR} ${PROMfilePattern} ${PROMbaseDir}/${PROMbaseConfig} > ${TEMPDIR}/prometheus_temp.yml
  # 組み立てたconfigと既存configをdiff
  diff ${PROMbaseDir}/${PROMresultConfig} ${TEMPDIR}/prometheus_temp.yml
  promConfigDiffResult=$?
  
  # ------ alert.rules 確認 ----- #
  # copy alertfiles from TEMPDIR and PROMbaseDir to TEMPDIR2
  mkdir -p ${TEMPDIR}/alert_base ${TEMPDIR}/alert_temp
  cp -r ${PROMbaseDir}/${PROMalertFilePattern} ${TEMPDIR}/alert_base/
  cp -r ${TEMPDIR}/${PROMalertFilePattern} ${TEMPDIR}/alert_temp/
  # compare alertfiles between current and S3
  diff ${TEMPDIR}/alert_base ${TEMPDIR}/alert_temp
  alertRulesDiffResult=$?



  if [ ${promConfigDiffResult} = 1 -o ${alertRulesDiffResult} = 1 ]; then
    echo "diff found"
    # 既存configを上書き
    echo "overwriting prometheus config"
    mv ${TEMPDIR}/prometheus_temp.yml ${PROMbaseDir}/${PROMresultConfig}
    echo "overwriting alert config"
    mv ${TEMPDIR}/${PROMalertFilePattern} ${PROMbaseDir}/
    # prometheusを再起動
    echo "Restarting prometheus.service"
    systemctl restart prometheus.service
  else
    echo "difference not found"
  fi

  # tempdir 削除
  echo "deleting ${TEMPDIR}"
  rm -rf ${TEMPDIR}
  
  echo "sleep for ${INTERVAL}"
  sleep ${INTERVAL}
done
