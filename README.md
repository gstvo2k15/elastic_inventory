```
JDK PATCHING PROCESS – MIDDLEWARE PLATFORMS

This document describes how to generate patch variable files and execute JDK patching
for Middleware platforms (WebLogic, Tomcat, JBoss EAP, JBoss EWS).

All operations are executed from the patching platform located at:

/testing


1. GO TO THE PATCHING PLATFORM

cd /testing


2. GENERATE VAR FILES

Var files define product, region, environment and change wave.

Example for WebLogic DEV/STG:

EUROPE
./generate_varfile.sh -file /apps/reporting/dpi_reports/patching/weblogic-devstg-EUROPE.txt \
-location MAIN -patch_product java -region EUROPE -patch_envs DEV,STG -patch_wave RUN001

ASIAN
./generate_varfile.sh -file /apps/reporting/dpi_reports/patching/weblogic-devstg-ASIAN.txt \
-location MAIN -patch_product java -region ASIAN -patch_envs DEV,STG -patch_wave RUN001

AMERICA
./generate_varfile.sh -file /apps/reporting/dpi_reports/patching/weblogic-devstg-AMERICA.txt \
-location MAIN -patch_product java -region AMERICA -patch_envs DEV,STG -patch_wave RUN001


Notes:
- For production environments, use PRD instead of DEV,STG
- Repeat the same process changing -patch_product for:
  tomcat
  jboss_ews
  jboss_eap


3. GENERATE ALL HOSTNAME FILES AUTOMATICALLY (OPTIONAL)

All required hostname files for all products can be generated with:

/apps/dpi-reports/reports/jdk-global-extract-hostname.sh

After this step, only patch execution is needed.


4. LAUNCH THE PATCH

Execute the patch using the generated var file.

Example (WebLogic DEV/STG EUROPE):

/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-EUROPE_MAIN_java_EUROPE_RUN001.yml

Repeat for ASIAN and AMERICA as needed.


5. PRODUCTION PATCHING

For production servers:
- Generate var files with patch_envs=PRD
- Launch the patch using the PRD var files


6. SCHEDULE PATCH EXECUTION (OPTIONAL)

Patches can be scheduled using at.

Example:

echo "cd /testing && \
/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-EUROPE_MAIN_java_EUROPE_RUN001.yml" \
| at 03:30 14.03.2025

Time format: HH:MM
Date format: DD.MM.YYYY


7. EXCLUDE SERVERS (OPTIONAL)

Specific servers can be excluded using an exclusion file.

Example:

echo "cd /testing && \
/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-EUROPE_MAIN_java_EUROPE_RUN001.yml \
-excludedfile /apps/reporting/dpi_reports/patching/exclude/RUN001-excluded-java-prd-EUROPE.txt" \
| at 01:00 08.03.2025


SUMMARY

- Generate hostname lists (optional)
- Generate var files per product, region and environment
- Execute or schedule the patch
- Optionally exclude servers
- Repeat for all Middleware products



Go the path to patch:

cd /testing


Generate the var files:

./generate_varfile.sh -file /apps/reporting/dpi_reports/patching/weblogic-devstg-EUROPE.txt \
-location MAIN -patch_product java -region EUROPE -patch_envs DEV,STG -patch_wave RUN001

./generate_varfile.sh -file /apps/reporting/dpi_reports/patching/weblogic-devstg-ASIAN.txt \
-location MAIN -patch_product java -region ASIAN -patch_envs DEV,STG -patch_wave RUN001

./generate_varfile.sh -file /apps/reporting/dpi_reports/patching/weblogic-devstg-AMERICA.txt \
-location MAIN -patch_product java -region AMERICA -patch_envs DEV,STG -patch_wave RUN001

…case of non-prod; from production use PRD


Repeat the process in -patch_product for tomcat / Jboss-EWS and Jboss EAP
to cover all JDK in all products.


You can create all files for all products with this script:
 /apps/dpi-reports/reports/jdk-global-extract-hostname.sh
and you only need to launch the patch.


Launch the Patch:

/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-EUROPE_MAIN_java_EUROPE_RUN001.yml

/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-ASIAN_MAIN_java_ASIAN_RUN001.yml

/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-AMERICA_MAIN_java_AMERICA_RUN001.yml


-- same steps for Production Servers adding PRD in patch_envs


Launch the Patch with some schedules:

echo "cd /testing && \
/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-EUROPE_MAIN_java_EUROPE_RUN001.yml" \
| at 03:30 14.03.2025

(day.month.year)


We can exclude some servers in case it is needed:

echo "cd /testing && \
/testing/run_patch_template.sh \
-varfile /testing/vars/weblogic-devstg-EUROPE_MAIN_java_EUROPE_RUN001.yml \
-excludedfile /apps/reporting/dpi_reports/patching/exclude/RUN001-excluded-java-prd-EUROPE.txt" \
| at 01:00 08.03.2025


Create the file with the server/s to patch

Path:
/testing/txt

Connect to bastion server and create the file
betaserver006.txt including the host betaserver006 to patch

touch betaserver006.txt

betaserver006


WARNING:
This file can not be empty or the template will Patch Everything
in the region and product selected


Generate the Var File

Path:
/testing/vars

In the same way we use extra vars in ansible tower we can launch
these values by command and update Java

/testing/generate_varfile.sh \
-file txt/betaserver006.txt \
-location MAIN \
-patch_product java \
-region ASIAN \
-patch_envs PRD \
-patch_wave rec-betaserver006


Where:
- Location can be MAIN / DMZ or (IBM Cloud)
- ASIAN is the Region
- patch_envs PRD is the environment
- patch_wave is a name used to follow the status in Elastic tool


Example generated var file:

[PRD][GEN2AUXMIDLW@bastionserver vars]$ more betaserver006_MAIN_java_ASIAN_rec-betaserver006.yml


custom_hosts_list:
  - betaserver006

generate_excel: 'False'

location: MAIN

patch_envs:
  - PRD

patch_product: java

patch_wave: 'rec-betaserver006'

previous_patch_wave: ''

region: ASIAN



Launch template

Path:
/testing

Once you have the Var file the last step is to launch the update:

/testing/run_patch_template.sh \
-varfile /testing/vars/betaserver006_MAIN_java_ASIAN_rec-betaserver006.yml


Verify the update in logs and Ansible Tower

Check in bastion this path:
/testing/logs

Or check in Ansible:
https://ansible-platform.cib.echonet
-> build_inventory_custom
-> patch_inventory_EUROPE (in case of EUROPE)

Anyway you can check in the updated host if the packages are already installed.

rpm -qa 

Example:
jdk8-1.8.0_441-0.el9.x86_64
```
