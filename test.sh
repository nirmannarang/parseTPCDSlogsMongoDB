#!/bin/bash -l

logDir=/root/parseTPCDSlogsMongoDB/logs

log_file_name=$(ls -lrt  ${logDir} | tail -2 | head -1 | awk -F " " '{print  $9 }')
#log_file="/root/parseTPCDSlogsMongoDB/q1,q2,q3_single_ppc64le_2e_1c_1g_3.nohup"
git_url="https://github.com/apache/spark"

#Get last commit hash of git 
#Usage: git log -n 1 [branch_name] branch_name(may be remote or local branch) is optional. Without branch_name it will show the latest commit of current branch.
#last_commit=$(git log -n 1 --pretty=format:"%H")
last_commit="1472cac4bb31c1886f82830778d34c4dd9030d7a"
#date=$(date +"%d-%m-%Y_%H:%M:%S")
master="10.20.3.144"
log_file=${logDir}/${log_file_name}
json_file=$(echo $log_file | cut -f 1 -d '.').json


python tpcdsExtractJSONtoMongoDB.py $log_file $git_url $last_commit $master

curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d @${json_file} http://127.0.0.1:9000/api/t_benchmark

rm -rf ${json_file}
#curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d '{"name": "TPCDS", "master": "10.20.3.144", "git_url": "https://github.com/apache/spark", "last_commit": "1472cac4bb31c1886f82830778d34c4dd9030d7a", "date": "23-03-2017_16:35:22", "workloads": [{"metrics": [{"name": "minTimeMs", "value": "10417.316601"}, {"name": "maxTimeMs", "value": "21206.434051"}, {"name": "avgTimeMs", "value": "15811.875326000001"}, {"name": "stdDev", "value": "7629.058111913111"}], "name": "q1-v1.4"}, {"metrics": [{"name": "minTimeMs", "value": "9587.276137"}, {"name": "maxTimeMs", "value": "16722.199964"}, {"name": "avgTimeMs", "value": "13154.7380505"}, {"name": "stdDev", "value": "5045.153021321173"}], "name": "q2-v1.4"}, {"metrics": [{"name": "minTimeMs", "value": "7914.537812"}, {"name": "maxTimeMs", "value": "14104.44932"}, {"name": "avgTimeMs", "value": "11009.493566"}, {"name": "stdDev", "value": "4376.9284022514485"}], "name": "q3-v1.4"}, {"metrics": [{"name": "minTimeMs", "value": "25249.22636"}, {"name": "maxTimeMs", "value": "30951.49686"}, {"name": "avgTimeMs", "value": "28100.36161"}, {"name": "stdDev", "value": "4032.114138710004"}], "name": "q4-v1.4"}]}' http://127.0.0.1:9000/api/t_benchmark



#curl -i -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d '{"name":"TPCDS","master":"10.20.3.144","git_url":"https://github.com/apache/spark","last_commit":"1472cac4bb31c1886f82830778d34c4dd9030d7a","date":"23-03-2017_16:35:22","workloads":[{"metrics":[{"name":"minTimeMs","value":"10417.316601"},{"name":"maxTimeMs","value":"21206.434051"},{"name":"avgTimeMs","value":"15811.875326000001"},{"name":"stdDev","value":"7629.058111913111"}],"name":"q1-v1.4"},{"metrics":[{"name":"minTimeMs","value":"9587.276137"},{"name":"maxTimeMs","value":"16722.199964"},{"name":"avgTimeMs","value":"13154.7380505"},{"name":"stdDev","value":"5045.153021321173"}],"name":"q2-v1.4"},{"metrics":[{"name":"minTimeMs","value":"7914.537812"},{"name":"maxTimeMs","value":"14104.44932"},{"name":"avgTimeMs","value":"11009.493566"},{"name":"stdDev","value":"4376.9284022514485"}],"name":"q3-v1.4"},{"metrics":[{"name":"minTimeMs","value":"25249.22636"},{"name":"maxTimeMs","value":"30951.49686"},{"name":"avgTimeMs","value":"28100.36161"},{"name":"stdDev","value":"4032.114138710004"}],"name":"q4-v1.4"}]}' http://127.0.0.1:9000/api/t_benchmark
