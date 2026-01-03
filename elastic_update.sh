#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $(basename "$0") --product <apache|tomcat|weblogic> --region <emea|apac|amer> --env <dev|stg|prd> [--location <CORE|DMZI|ETS>]

Example:
  $(basename "$0") --product apache --region emea --env dev
EOF
  exit 2
}

product=""
region=""
env=""
location="CORE"
wave=""

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && usage

while [[ $# -gt 0 ]]; do
  case "$1" in
    --product) product="$2"; shift 2 ;;
    --region) region="$2"; shift 2 ;;
    --env) env="$2"; shift 2 ;;
    --location) location="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -n "$product" && -n "$region" && -n "$env" ]] || usage

product_lc="$(printf '%s' "$product" | tr '[:upper:]' '[:lower:]')"
region_uc="$(printf '%s' "$region" | tr '[:lower:]' '[:upper:]')"
region_lc="$(printf '%s' "$region" | tr '[:upper:]' '[:lower:]')"
env_uc="$(printf '%s' "$env" | tr '[:lower:]' '[:upper:]')"
env_lc="$(printf '%s' "$env" | tr '[:upper:]' '[:lower:]')"
location_uc="$(printf '%s' "$location" | tr '[:lower:]' '[:upper:]')"

launch_limit="${product_lc}_${region_lc}_${env_lc}"

extra="{\"product\":\"${product_lc}\",\"region\":\"${region_uc}\",\"data_env\":\"${env_lc}\",\"location\":\"${location_uc}\",\"launch_limit\":\"${launch_limit}\""
if [[ -n "$wave" ]]; then
  extra="${extra},\"patch_wave\":\"${wave}\""
fi
extra="${extra}}"

jt="adhoc_template_elastic"

awx -k job_templates launch "$jt" \
  --extra-vars "$extra" \
  --verbosity 0 \
  --monitor -f human
