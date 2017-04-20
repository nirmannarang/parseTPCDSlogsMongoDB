#!/bin/bash -l
SLAVES=`cat ${HADOOP_HOME}/etc/hadoop/slaves | tr "\n" " "`
echo "Collecting hardware config details for Master machine `hostname`"
ip=`hostname --ip-address`
hostname=`hostname`
RAM=`free -g | head -2 | tail -1 | awk {'print $2'}`
vcpu=`cat /proc/cpuinfo | grep processor | wc -l`
echo "{" > config_details
echo "\"master\": {\"ip\":\"$ip\",\"hostname\":\"$hostname\",\"vcpus\":$vcpu,\"RAM\":\"${RAM}GB\"}," >> config_details
echo "\"slaves\": [" >> config_details
#echo "$ip,$hostname,${RAM}GB,$vcpu" >> config_details

count=`cat ${HADOOP_HOME}/etc/hadoop/slaves | wc -l`
for server in $SLAVES
do
echo "Collecting hardware config details for slave machine ${server}"
ip=$( ssh $server "hostname --ip-address")
hostname=$(ssh $server "hostname")
RAM=$(ssh $server "free -g" | head -2 | tail -1 | awk {'print $2'})
vcpu=$(ssh $server "cat /proc/cpuinfo | grep processor | wc -l")
#echo "$ip,$hostname,${RAM}GB,$vcpu">>config_details
echo "{\"ip\":\"$ip\",\"hostname\":\"$hostname\",\"vcpus\":$vcpu,\"RAM\":\"${RAM}GB\"}" >> config_details
if [ $count -ne 1 ]
then 
	echo "," >> config_details
fi
((count=count-1))
done
echo "]" >> config_details
echo "}" >> config_details
