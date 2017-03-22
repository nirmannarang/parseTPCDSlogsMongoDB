#!/usr/bin/python

import re
import json

#q1,q2,q3_single_ppc64le_2e_1c_1g_0 NaN case
#tfile=open('C:/Users/nirman_narang/Documents/q1_single_ppc64le_12e_1c_1g_3.nohup', 'rt')
tfile=open('C:/Users/nirman_narang/Documents/q1,q2,q3_single_ppc64le_2e_1c_1g_0.nohup', 'rt')
contents=tfile.readlines()
content=tfile.read()
name = "TPCDS"
git_url = "https://github.com/apache/spark"
last_commit = "1472cac4bb31c1886f82830778d34c4dd9030d7a"
date = "2016-03-15T18:25:43.511Z"
master = "10.20.3.144"
queryList=[]
flag=0
#regex=re.compile('\|name\s*\|minTimeMs\s*\|maxTimeMs\s*\|avgTimeMs\s*\|')
regex=re.compile(r"\|(q\d+-?v?\d*\.?\d*)\s*\|((\d*\.?\d*)|(NaN))\s*\|((\d*\.?\d*)|(NaN))\s*\|((\d*\.?\d*)|(NaN))\s*\|((\d*\.?\d*)|(NaN))\s*\|")
#\|(q\d+-v\d+\.?\d*)\s*\|((\d+\.?\d*)|(NaN))\s*\|((\d+\.?\d*)|(NaN))\s*\|((\d+\.?\d*)|(NaN))\s*\|((\d+\.?\d*)|(NaN))\s*\|
#|q1-v1.4|10417.316601|21206.434051|15811.875326000001|7629.058111913111 |2    |12  |1    |1g |

dict_stats={}
dict_stats["name"]=name
dict_stats["git_url"]=git_url
dict_stats["last_commit"]=last_commit
dict_stats["date"]=date
dict_stats["master"]=master



for line in contents:
	#print(line)
	if "QUERY LIST END" in line:
		break
	if "== QUERY LIST ==" in line:
		flag=1
		continue
	if flag == 1:
		queryList.append(line.strip())
print(queryList)

workloads=[]
dict_temp={}
metrics_temp=[]


for lines in contents:
	result = regex.search(lines)
	if result:
		print("found")
		dict_temp.clear()
		metrics_temp=[]
		#print(result.group(1))
		query=str(result.group(1))
		#print(result.group(2))
		minTimeMs=str(result.group(2))
		#print(result.group(5))
		maxTimeMs=str(result.group(5))
		#print(result.group(8))
		avgTimeMs=str(result.group(8))
		#print(result.group(11))
		stdDev=str(result.group(11))
		dict_temp["name"]="minTimeMs"
		dict_temp["value"]=minTimeMs
		metrics_temp.append(dict_temp.copy())
		dict_temp["name"]="maxTimeMs"
		dict_temp["value"]=maxTimeMs
		metrics_temp.append(dict_temp.copy())
		dict_temp["name"]="avgTimeMs"
		dict_temp["value"]=avgTimeMs
		metrics_temp.append(dict_temp.copy())
		dict_temp["name"]="stdDev"
		dict_temp["value"]=stdDev
		metrics_temp.append(dict_temp.copy())
		#print(metrics_temp)
		dict_temp.clear()
		dict_temp["name"]=query
		dict_temp["metrics"]=metrics_temp
		#print(dict_temp)
		workloads.append(dict_temp.copy())

dict_stats["workloads"]=workloads
json_string=json.dumps(dict_stats)
print(json_string)
#print(dict_stats)