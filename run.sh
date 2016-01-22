#!/bin/bash
#
# Count code lines with cloc
#   for running cloc under Jenkins
#
# Support:
#  Counting of all lines for all projects on Jenkins server
#  Counting of lines for only project running this script
#  Counting of lines for some group of projects on Jenkins server
#
# Use with SLOCcount plugin
#
# Expected Jenkins job parameters:
#   Count_Jobs  : ALL, PROJECT, or GROUP
#   Project     : Job name to process
#   Include     : For GROUP, find -name arg of things to include
#   Exclude     : For GROUP, find -name arg of directories to exclude
#
# Examples:
#   Process all jobs that start with 'Puppet_' except the ones that start with 'Puppet_Control'
#   run.sh GROUP 'Puppet_*' 'Puppet_Control*'
#

cloc=./cloc
file_list=workspace_dirs
file_report=cloc.xml

if [ $# -eq 0 ] || [ "$Count_Jobs" = 'ALL' ]; then
  # Report on all jobs on Jenkins server
  find $JENKINS_HOME/jobs/ -type d -name workspace > $file_list
elif [ "$Count_Jobs" = 'PROJECT' ]; then
  # Report on current project/job
  echo "$JENKINS_HOME/jobs/$2/workspace" > $file_list
  file_report="$JENKINS_HOME/jobs/$2/workspace/$file_report"
elif [ "$Count_Jobs" = 'GROUP' ]; then
  # Report on a group of projects/jobs
  if [ -n "$3" ]; then
    exclude="-type d -name '$3' -prune -o"
  fi
  #find $JENKINS_HOME/jobs -type d -name "$3" -prune -o -type d -path "$2" -name workspace -print > $file_list
  find $JENKINS_HOME/jobs $exclude -type d -path "$2" -name workspace -print > $file_list
else
  echo "ERROR: parameters not understood"
  exit 1
fi

$cloc --by-file --xml --out=$file_report --list-file=$file_list

