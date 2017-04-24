#!/bin/bash -l
WORKDIR=${HOME}
SLAVES=`cat ${HADOOP_HOME}/etc/hadoop/slaves | tr "\n" " "`
echo "Collecting hardware config details for Master machine `hostname`"
ip=`hostname --ip-address`
hostname=`hostname`
ram=`free -g | head -2 | tail -1 | awk {'print $2'}`
vcpu=`cat /proc/cpuinfo | grep processor | wc -l`
echo "{" > ${WORKDIR}/config_details
echo "\"master\": {\"ip\":\"$ip\",\"hostname\":\"$hostname\",\"vcpus\":$vcpu,\"ram\":\"${ram}GB\"}," >> ${WORKDIR}/config_details
echo "\"slaves\": [" >> ${WORKDIR}/config_details
#echo "$ip,$hostname,${RAM}GB,$vcpu" >> config_details

count=`cat ${HADOOP_HOME}/etc/hadoop/slaves | wc -l`
for server in $SLAVES
do
echo "Collecting hardware config details for slave machine ${server}"
ip=$( ssh $server "hostname --ip-address")
hostname=$(ssh $server "hostname")
ram=$(ssh $server "free -g" | head -2 | tail -1 | awk {'print $2'})
vcpu=$(ssh $server "cat /proc/cpuinfo | grep processor | wc -l")
#echo "$ip,$hostname,${RAM}GB,$vcpu">>config_details
echo "{\"ip\":\"$ip\",\"hostname\":\"$hostname\",\"vcpus\":$vcpu,\"ram\":\"${ram}GB\"}" >> ${WORKDIR}/config_details
if [ $count -ne 1 ]
then 
	echo "," >> ${WORKDIR}/config_details
fi
((count=count-1))
done
echo "]" >> ${WORKDIR}/config_details
echo "}" >> ${WORKDIR}/config_details
