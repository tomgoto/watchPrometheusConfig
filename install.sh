#!/bin/bash


INSTALLDIR="/opt/watchPrometheus"

mkdir -p ${INSTALLDIR}
cp merge_prometheusConfigs.sh ${INSTALLDIR}/
cp merge_alertmanagerConfigs.sh ${INSTALLDIR}/
cp watchPrometheusConfig.sh ${INSTALLDIR}/
chmod a+x ${INSTALLDIR}/*.sh

cp watchPrometheusConfig.service /etc/systemd/system/
cp watchPrometheusConfig /etc/default/
systemctl daemon-reload
systemctl enable watchPrometheusConfig.service
# systemctl start watchPrometheusConfig.service