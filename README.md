# Elastic inventory repo for tower template execution

Usage:

**Note**: Generate previosly adhoc_template_elastic template in tower with inventory & credentials for localhost.

```bash
awx -k job_templates launch "adhoc_template_elastic" \
  --extra-vars '{"product":"apache","inventory_name":"apache","region":"EMEA","data_env":"dev","location":"CORE","launch_limit":"apache_dev_emea"}' \
  --verbosity 0 \
  --monitor -f human
```
