#!/bin/bash -l
WORKDIR=${HOME}
SLAVES=`cat ${HADOOP_HOME}/etc/hadoop/slaves | tr "\n" " "`
echo "Collecting hardware config details for Master machine `hostname`"
ip=`hostname --ip-address`
hostname=`hostname`
ram=`free -g | head -2 | tail -1 | awk {'print $2'}`
vcpu=`cat /proc/cpuinfo | grep processor | wc -l`
echo "{" > ${WORKDIR}/cluster_info
echo "\"master\": {\"ip\":\"$ip\",\"hostname\":\"$hostname\",\"vcpus\":$vcpu,\"ram\":\"${ram}GB\"}," >> ${WORKDIR}/cluster_info
echo "\"slaves\": [" >> ${WORKDIR}/cluster_info
#echo "$ip,$hostname,${RAM}GB,$vcpu" >> cluster_info

count=`cat ${HADOOP_HOME}/etc/hadoop/slaves | wc -l`
for server in $SLAVES
do
echo "Collecting hardware config details for slave machine ${server}"
ip=$( ssh $server "hostname --ip-address")
hostname=$(ssh $server "hostname")
ram=$(ssh $server "free -g" | head -2 | tail -1 | awk {'print $2'})
vcpu=$(ssh $server "cat /proc/cpuinfo | grep processor | wc -l")
#echo "$ip,$hostname,${RAM}GB,$vcpu">>cluster_info
echo "{\"ip\":\"$ip\",\"hostname\":\"$hostname\",\"vcpus\":$vcpu,\"ram\":\"${ram}GB\"}" >> ${WORKDIR}/cluster_info
if [ $count -ne 1 ]
then 
	echo "," >> ${WORKDIR}/cluster_info
fi
((count=count-1))
done
echo "]" >> ${WORKDIR}/cluster_info
echo "}" >> ${WORKDIR}/cluster_info
