#!/bin/bash

# usage
# ./merge_prometheusConfigs.sh <DIR_PATH> <FILE_PATTERN> <BASE_YAML>
#
# example
# /opt/merge_prometheusConfigs.sh /mnt/prometheusSetting prometheusConfig*.yaml /opt/prometheus/base_prometheus.yml   > /opt/prometheus/prometheus.yml


DIR_PATH=$1
FILE_PATTERN=$2
BASE_YAML=$3

FILELIST=`find ${DIR_PATH} -name ${FILE_PATTERN}`

# base_yamlをjsonに変換
TEMPDIR=`mktemp -d`
cat ${BASE_YAML} | yq . > ${TEMPDIR}/temp_base.json

# 各ファイルをjsonに追記
for eachFile in ${FILELIST}; do
  # scrape_configs
  contentsJSON=$(cat $eachFile | yq ."scrape_configs"[])
  cat ${TEMPDIR}/temp_base.json | jq ".scrape_configs |= .+[${contentsJSON}]" > ${TEMPDIR}/temp.json
  mv ${TEMPDIR}/temp.json ${TEMPDIR}/temp_base.json

  # rule_files
  contentsJSON=$(cat $eachFile | yq ."rule_files"[])
  cat ${TEMPDIR}/temp_base.json | jq ".rule_files |= .+[${contentsJSON}]" > ${TEMPDIR}/temp.json
  mv ${TEMPDIR}/temp.json ${TEMPDIR}/temp_base.json
done


# 追記したjsonをYAMLに変換
python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' < ${TEMPDIR}/temp_base.json

# TEMPDIR削除
rm -rf ${TEMPDIR}