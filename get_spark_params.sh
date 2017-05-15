#!/bin/bash -l
WORKDIR=${HOME}
logfile=`ls -ltr ${WORKDIR}/tpcds-setup/logs/*.nohup | tail -1 | awk {'print $9'}`

num_executors=`grep numExecutors $logfile | awk {'print $2'}`
executor_cores=`grep executorCores $logfile | awk {'print $2'}`
executor_memory=`grep executorMemory $logfile | awk {'print $2'}`
driver_memory=`grep driverMemory $logfile | awk {'print $2'}`
driver_cores=`grep driverCores $logfile | awk {'print $2'}`
total_executor_cores=`grep totalExecutorCores $logfile | awk {'print $2'}`
shuffle_partitions=`grep "spark.sql.shuffle.partitions" $logfile  | head -1 | sed 's/->//' | sed 's/,/ /' | sed 's/)//' | sed 's/(//' |awk  {'print $2'}`
gc_threads=`grep "spark.executor.extraJavaOptions" $logfile | head -1 |cut -f3 -d"=" | awk {'print $1'}`
exec_memoryOverhead=`grep "spark.yarn.executor.memoryOverhead" $logfile | head -1 | sed 's/->//' | sed 's/,/ /' | sed 's/)//' | sed 's/(//' |awk  {'print $2'}`
driver_memoryOverhead=`grep "spark.yarn.driver.memoryOverhead" $logfile | head -1 | sed 's/->//' | sed 's/,/ /' | sed 's/)//' | sed 's/(//' |awk  {'print $2'}`


echo "{" >${WORKDIR}/spark_params
echo "\"num_executors\":\"$num_executors\"," >>${WORKDIR}/spark_params
echo "\"executor_cores\":\"$executor_cores\"," >>${WORKDIR}/spark_params
echo "\"executor_memory\":\"$executor_memory\"," >>${WORKDIR}/spark_params
echo "\"driver_memory\":\"$driver_memory\"," >>${WORKDIR}/spark_params
echo "\"driver_cores\":\"$driver_cores\"," >>${WORKDIR}/spark_params
echo "\"total_executor_cores\":\"$total_executor_cores\"," >>${WORKDIR}/spark_params
echo "\"shuffle_partitions\":\"$shuffle_partitions\"," >>${WORKDIR}/spark_params
echo "\"gc_threads\":\"$gc_threads\"," >>${WORKDIR}/spark_params
echo "\"exec_memoryOverhead\":\"$exec_memoryOverhead\"," >>${WORKDIR}/spark_params
echo "\"driver_memoryOverhead\":\"$driver_memoryOverhead\"" >>${WORKDIR}/spark_params
echo "}" >>${WORKDIR}/spark_params

