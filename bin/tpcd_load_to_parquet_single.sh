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


set_env() {
  # read -n1 -s
  TEST_ROOT=`pwd`
  set_environment
  . $TPCDS_ROOT_DIR/bin/tpcdsenv.sh
  echo "SPARK_HOME is " $SPARK_HOME
  set_environment
}

template(){
    # usage: template file.tpl
    while read -r line ; do
            line=${line//\"/\\\"}
            line=${line//\`/\\\`}
            line=${line//\$/\\\$}
            line=${line//\\\${/\${}
            eval "echo \"$line\""; 
    done < ${1}
}

set_env
DRIVER_OPTIONS="--driver-java-options -Dlog4j.configuration=file:///${output_dir}/log4j.properties"
EXECUTOR_OPTIONS="--conf spark.executor.extraJavaOptions=-Dlog4j.configuration=file:///${output_dir}/log4j.properties"

output_dir=$TPCDS_WORK_DIR
cleanup $TPCDS_WORK_DIR
for i in `ls ${TPCDS_ROOT_DIR}/src/ddl/individual/*.sql`
do
  baseName="$(basename $i)"
  template $i > ${output_dir}/$baseName
done 
for i in `ls ${TPCDS_ROOT_DIR}/src/ddl/create_database.sql`
do
  baseName="$(basename $i)"
  template $i > ${output_dir}/$baseName
done 
for i in `ls ${TPCDS_ROOT_DIR}/src/properties/*`
do
  baseName="$(basename $i)"
  template $i > ${output_dir}/$baseName
done 

${SPARK_HOME}/bin/spark-sql ${DRIVER_OPTIONS} ${EXECUTOR_OPTIONS} --conf spark.sql.catalogImplementation=hive -f ${TPCDS_WORK_DIR}/create_database.sql > ${TPCDS_WORK_DIR}/create_database.out 2>&1
${SPARK_HOME}/bin/spark-sql ${DRIVER_OPTIONS} ${EXECUTOR_OPTIONS} --conf spark.sql.catalogImplementation=hive -f ${TPCDS_WORK_DIR}/create_tables.sql > ${TPCDS_WORK_DIR}/create_tables.out 2>&1
