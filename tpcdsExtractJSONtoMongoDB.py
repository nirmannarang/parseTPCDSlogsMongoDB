#!/usr/bin/python

import sys
import re
import json
import datetime
from decimal import Decimal
import collections

#q1,q2,q3_single_ppc64le_2e_1c_1g_0 NaN case
if len(sys.argv) != 8:
    print("All arguments are not passed !!")
    exit()

logFile=sys.argv[1]
git_url=sys.argv[2]
last_commit=sys.argv[3]
#date=sys.argv[4]
#print(logFile)
master=sys.argv[4]
git_branch=sys.argv[5]
cluster_file=sys.argv[6]
spark_param_file=sys.argv[7]
tfile=open(logFile, 'rt')
contents=tfile.readlines()
content=tfile.read()
name = "TPCDS"
jsonFileName=logFile.strip(".nohup")+".json"
#git_url = "https://github.com/apache/spark"
#last_commit = "1472cac4bb31c1886f82830778d34c4dd9030d7a"
#date = "2016-03-15T18:25:43.511Z"
#date="2016-03-15T18:25:43.511Z"
#print(jsonFileName)
date=datetime.datetime.utcnow()
date_str=date.strftime("%Y-%m-%dT%H:%M:%S.%f")
date_str=date_str[:-3]
date_str=date_str+'Z'
#print(date_str)
#date="2017-03-24T11:51:40.916251"
#master = "10.20.3.144"
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
dict_stats["date"]=date_str
dict_stats["master"]=master
dict_stats["branch"]=git_branch
workloads=[]
dict_temp={}
metrics_temp=[]
roundTwoPlaces = Decimal(10) ** -2

for lines in contents:
	result = regex.search(lines)
	if result:
		#print("found")
		dict_temp.clear()
		metrics_temp=[]
		#print(result.group(1))
		query=str(result.group(1))
		#print(result.group(2))    format(1.679, '.2f')   Decimal('3.214').quantize(TWOPLACES) "{0:.2f}".format(5)
		minTimeMs=float(Decimal(result.group(2)).quantize(roundTwoPlaces))
		#print(result.group(5))
		maxTimeMs=float(Decimal(result.group(5)).quantize(roundTwoPlaces))
		#print(result.group(8))
		avgTimeMs=float(Decimal(result.group(8)).quantize(roundTwoPlaces))
		#print(result.group(11))
		stdDev=result.group(11)
		if stdDev == 'NaN':
			stdDev=float(Decimal('0').quantize(roundTwoPlaces))
		else:
			stdDev=float(Decimal(result.group(11)).quantize(roundTwoPlaces))
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

def convert_unicode_dict(dict_cluster):
	if isinstance(dict_cluster, basestring):
		return str(dict_cluster)
	elif isinstance(dict_cluster, collections.Mapping):
		return dict(map(convert_unicode_dict, dict_cluster.iteritems()))
	elif isinstance(dict_cluster, collections.Iterable):
		return type(dict_cluster)(map(convert_unicode_dict, dict_cluster))
	else:
		return dict_cluster

tfile.close()
dict_stats["workloads"]=workloads

def validateDict(dict_test):
	if dict_test["workloads"]==[]:
		print("TPCDS failed to create metrics for this run")
		sys.exit(1)



cluster_f=open(cluster_file,'rt')
cluster_str=cluster_f.read()
cluster_unicode_dict=json.loads(cluster_str)
cluster_dict=convert_unicode_dict(cluster_unicode_dict)
cluster_f.close()
dict_stats["cluster_info"]=cluster_dict

spark_param_f=open(spark_param_file,'rt')
spark_param_str=spark_param_f.read()
spark_param_unicode_dict=json.loads(spark_param_str)
spark_param_dict=convert_unicode_dict(spark_param_unicode_dict)
spark_param_f.close()
dict_stats["spark_params"]=spark_param_dict

json_string=json.dumps(dict_stats)

validateDict(dict_stats)

#print(cluster_dict)

#print("-----------------------------------------------")

#print(dict_stats)

#print(dict_stats)
#print(json_string)
jsonFile=open(jsonFileName, "wb")
jsonFile.write(json_string)
jsonFile.close()
print("Json file created successfully")
