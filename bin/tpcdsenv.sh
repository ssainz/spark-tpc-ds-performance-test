#!/bin/bash
#
# tpcdsenv.sh - UNIX Environment Setup
#

#######################################################################
# This is a mandatory parameter. Please provide the location of
# spark installation.
#######################################################################
export SPARK_HOME=/Users/ssainz/spark221

#######################################################################
# Script environment parameters. When they are not set the script
# defaults to paths relative from the script directory.
#######################################################################

export TPCDS_ROOT_DIR=/Users/ssainz/Projects/ssainz/spark-tpc-ds-performance-test
export TPCDS_LOG_DIR=/Users/ssainz/Projects/ssainz/spark-tpc-ds-performance-test/log
export TPCDS_DBNAME=tpcds
export TPCDS_GENDATA_DIR=/Users/ssainz/Projects/ssainz/spark-tpc-ds-performance-test/gendata
export TPCDS_GEN_QUERIES_DIR=/Users/ssainz/Projects/ssainz/spark-tpc-ds-performance-test/genqueries
export TPCDS_WORK_DIR=/Users/ssainz/Projects/ssainz/spark-tpc-ds-performance-test/work
export TPCDS_LOAD_ROOT=/Users/ssainz/Projects/ssainz/tpcds_load
export JAVA_OPTS="-Xmx3g -Xms3g"