#!/bin/bash

source /apps/patching/.token-plat

FLD=/apps/patching/plat
LOG_FOLD=/apps/patching/plat/logs
logfile=$LOG_FOLD/run-patch-linux-$(date +%Y-%d-%m_%Hh%M).log

function usage() {
  echo "usage: $0 -varfile xxxx"
  exit 1
}

if [ "$#" -lt 2 ]; then
  echo "not enough args"
  usage
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    -varfile)
      varfile="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$varfile" ]; then
  usage
fi

if [ ! -f "${varfile}" ]; then
  echo "file not found"
  usage
fi

cd $FLD

awx -k job_templates launch 'build_mdw_inventory_custom' \
  --extra_vars @"${varfile}" \
  --verbosity 0 \
  --monitor -f human | tee -a "${logfile}"

echo done
