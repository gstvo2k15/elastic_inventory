#!/bin/bash

source /apps/patching/.token-plat

FLD=/apps/patching/plat
VAR_FOLD=$FLD/vars
LOG_FOLD=$FLD/logs

function usage(){
    echo "usage: $0 -file xxxx"
    exit 1
}

if [ "$#" -lt 2 ]; then
    echo "not enough args"
    usage
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    -file)
      csvfile="$2"
      shift 2
      ;;
    -location)
      location="$2"
      shift 2
      ;;
    -patch_envs)
      patch_envs="$2"
      shift 2
      ;;
    -patch_product)
      patch_product="$2"
      shift 2
      ;;
    -patch_wave)
      patch_wave="$2"
      shift 2
      ;;
    -previous_patch_wave)
      previous_patch_wave="$2"
      shift 2
      ;;
    -region)
      region="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$csvfile" ]; then
  usage
fi


if [ ! -f "${csvfile}" ]; then
  echo "file not found"
  usage
fi

if [[ $region != @(EMEA|AMER|APAC) ]]; then
  usage
fi

if [ -z "$location" ]; then
  usage
fi

if [[ $location != @(CORE|DMZI|ETS) ]]; then
  usage
fi

if [ -z "$patch_product" ]; then
  usage
fi

if [[ $patch_product != @(all|java|jboss_ews|jbosseap|tomcat|apache) ]]; then
  usage
fi

if [ -z "$patch_envs" ]; then
  usage
fi

cd $FLD

varfile="${VAR_FOLD}/$(basename -- ${csvfile%%.*})_${location}_${patch_product}_${region}_${patch_wave}.yml"
echo $varfile

echo "custom_hosts_list:" > $varfile
awk 'NF {print "  - " $0}' ${csvfile} >> $varfile
echo >> $varfile

echo "generate_excel: 'False'" >> $varfile
echo "location: ${location}" >> $varfile

echo "patch_envs:" >> $varfile
echo "$patch_envs" | awk -F',' '{for (i=1; i<=NF; i++) print "  - "$i}' >> $varfile
echo "patch_product: ${patch_product}" >> $varfile
echo "patch_wave: '${patch_wave}'" >> $varfile
echo "previous_patch_wave: ''" >> $varfile
echo "region: ${region}" >> $varfile

echo >> $varfile
echo done
