#!/bin/bash 
set_environment() {
  bin_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  script_dir="$(dirname "$bin_dir")"
  
  if [ -z "$TPCDS_ROOT_DIR" ]; then
     TPCDS_ROOT_DIR=${script_dir}
  fi  
  if [ -z "$TPCDS_LOG_DIR" ]; then
     TPCDS_LOG_DIR=${script_dir}/log
  fi  
  if [ -z "$TPCDS_DBNAME" ]; then
     TPCDS_DBNAME="TPCDS"
  fi  
  if [ -z "$TPCDS_GENDATA_DIR" ]; then
     TPCDS_GENDATA_DIR=${TPCDS_ROOT_DIR}/gendata
  fi  
  if [ -z "$TPCDS_GEN_QUERIES_DIR" ]; then
     TPCDS_GENQUERIES_DIR=${TPCDS_ROOT_DIR}/genqueries
  fi  
  if [ -z "$TPCDS_WORK_DIR" ]; then
     TPCDS_WORK_DIR=${TPCDS_ROOT_DIR}/work
  fi  
}

set_env() {
  # read -n1 -s
  TEST_ROOT=`pwd`
  set_environment
  . $TPCDS_ROOT_DIR/bin/tpcdsenv.sh
  echo "SPARK_HOME is " $SPARK_HOME
  set_environment
}

cleanup() {
  if [ -n "$1" ]; then
    rm -rf $1/*.log
    rm -rf $1/*.txt
    rm -rf $1/*.sql
    rm -rf $1/*.properties
    rm -rf $1/*.out
    rm -rf $1/*.res
    rm -rf $1/*.dat
    rm -rf $1/*.rrn
    rm -rf $1/*.tpl
    rm -rf $1/*.lst
    rm -rf $1/README
  fi
}



set_env
OUTPUT_DIR=$TPCDS_WORK_DIR
cleanup $TPCDS_WORK_DIR
DRIVER_OPTIONS="--driver-memory 4g --driver-java-options -Dlog4j.configuration=file:///${OUTPUT_DIR}/log4j.properties"
EXECUTOR_OPTIONS="--executor-memory 2g --num-executors 1 --conf spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///${OUTPUT_DIR}/log4j.properties --conf spark.sql.crossJoin.enabled=true"

cp ${TPCDS_GENQUERIES_DIR}/*.sql $TPCDS_WORK_DIR



divider===============================
divider=$divider$divider
header="\n %-10s  %11s %15s\n"
format=" %-10s %10s %10s\n" 
width=50
printf "$header" "ID" "Query" "Time(secs)" "Rows returned" > ${OUTPUT_DIR}/run_summary.txt
printf "%$width.${width}s\n" "$divider" >> ${OUTPUT_DIR}/run_summary.txt


touch ${TPCDS_WORK_DIR}/runlist.txt
for i in `seq 1 99`
do
  echo "$i" >> ${TPCDS_WORK_DIR}/runlist.txt
done

for i in `cat ${TPCDS_ROOT_DIR}/runblacklist.txt`;
do
  rm ${TPCDS_WORK_DIR}/query$i.sql
done 

for i in `cat ${OUTPUT_DIR}/runlist.txt`;
do
  num=`printf "%02d\n" $i`
  scala -classpath ${TPCDS_LOAD_ROOT}/lib/tpcds_load.jar:${TPCDS_LOAD_ROOT}/lib/datanucleus-core-3.2.10.jar:${TPCDS_LOAD_ROOT}/lib/datanucleus-api-jdo-3.2.6.jar:${TPCDS_LOAD_ROOT}/lib/datanucleus-rdbms-3.2.9.jar:${TPCDS_LOAD_ROOT}/lib/spark-csv_2.11-1.4.0.jar:${TPCDS_LOAD_ROOT}/lib/parquet-common-1.8.2.jar:${TPCDS_LOAD_ROOT}/lib/parquet-column-1.8.2.jar:${TPCDS_LOAD_ROOT}/lib/parquet-encoding-1.8.2.jar:${TPCDS_LOAD_ROOT}/lib/parquet-format-2.3.1.jar:${TPCDS_LOAD_ROOT}/lib/parquet-hadoop-1.8.2.jar:${TPCDS_LOAD_ROOT}/lib/parquet-jackson-1.8.2.jar:${TPCDS_LOAD_ROOT}/lib/hive-exec-1.2.1.spark2.jar:${TPCDS_LOAD_ROOT}/lib/spark-sql_2.11-2.2.1.jar:${TPCDS_LOAD_ROOT}/lib/parquet-hadoop-bundle-1.6.0.jar  execute_sql_script ${OUTPUT_DIR}/query${num}.sql > ${OUTPUT_DIR}/query${num}.res 2>&1
  lines=`cat ${OUTPUT_DIR}/query${num}.res | grep "Time taken:"`
  echo "$lines" | while read -r line; 
  do
    name=`echo $line | tr -s " " " " | cut -d " " -f2`
    time=`echo $line | tr -s " " " " | cut -d " " -f5`
    num_rows=`echo $line | tr -s " " " " | cut -d " " -f8`
    printf "$format" \
       $name \
       $time \
       $num_rows >> ${OUTPUT_DIR}/run_summary.txt 
  done 

done 
touch ${OUTPUT_DIR}/queryfinal.res
