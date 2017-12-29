#!/bin/bash

read -p "Username: " USER
read -s -p "Password: " PASS
echo ""
JENKINS_HOST=$USER:$PASS@localhost:8080
curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/' > plugins.txt
