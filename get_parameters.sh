#!/bin/bash -l
WORKDIR=${HOME}
logfile=`ls -ltr ${WORKDIR}/tpcds-setup/logs/*.nohup | tail -1 | awk {'print $9'}`

num_executors=`grep numExecutors $logfile | awk {'print $2'}`
executor_cores=`grep executorCores $logfile | awk {'print $2'}`
executor_memory=`grep executorMemory $logfile | awk {'print $2'}`
driver_memory=`grep driverMemory $logfile | awk {'print $2'}`
driver_cores=`grep driverCores $logfile | awk {'print $2'}`
total_executor_cores=`grep totalExecutorCores $logfile | awk {'print $2'}`
shuffle_partitions=`grep "^spark.sql.shuffle.partitions" $logfile | awk {'print $3'}`
gc_threads=`grep "^spark.executor.extraJavaOptions" $logfile | cut -f3 -d"=" | awk {'print $1'}`
exec_memoryOverhead=`grep "^spark.yarn.executor.memoryOverhead" $logfile | awk {'print $3'}`
driver_memoryOverhead=`grep "^spark.yarn.driver.memoryOverhead" $logfile | awk {'print $3'}`

echo "{" >${WORKDIR}/paramters.json
echo "\"num_executors\":\"$num_executors\"," >>${WORKDIR}/paramters.json
echo "\"executor_cores\":\"$executor_cores\"," >>${WORKDIR}/paramters.json
echo "\"executor_memory\":\"$executor_memory\"," >>${WORKDIR}/paramters.json
echo "\"driver_memory\":\"$driver_memory\"," >>${WORKDIR}/paramters.json
echo "\"driver_cores\":\"$driver_cores\"," >>${WORKDIR}/paramters.json
echo "\"total_executor_cores\":\"$total_executor_cores\"," >>${WORKDIR}/paramters.json
echo "\"shuffle_partitions\":\"$shuffle_partitions\"," >>${WORKDIR}/paramters.json
echo "\"gc_threads\":\"$gc_threads\"," >>${WORKDIR}/paramters.json
echo "\"exec_memoryOverhead\":\"$exec_memoryOverhead\"," >>${WORKDIR}/paramters.json
echo "\"driver_memoryOverhead\":\"$driver_memoryOverhead\"" >>${WORKDIR}/paramters.json
echo "}" >>${WORKDIR}/paramters.json


