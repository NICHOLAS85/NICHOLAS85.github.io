#!/bin/bash

for file in ./debs/*; do
  info="$(dpkg-deb -I ${file})"
  package="$(echo "${info}" | awk '/Package/{print $2}')"
  if ! [[ -d "./depictions/${package}" ]]; then
    cp -r ./depictions/TEMPLATE "./depictions/${package}"
    name="$(echo "${info}" | awk '/Name/{print $2}')"
    version="$(echo "${info}" | awk '/Version/{print $2}')"
    miniOS="UNKNOWN"
    dependencies="$(echo "${info}" | awk '/Depends/{gsub(", ","</package>\n<package>"); gsub(" Depends: ","<package>");print $0"</package>"}')"
    shortdescription="$(echo "${info}" | awk '/Description/{gsub(" "$1" ","");print}')"
    longdescription="<description>${shortdescription}</description>"
    export package name version miniOS dependencies shortdescription longdescription
    envsubst < "./depictions/${package}/info.xml" > "./depictions/${package}/info.xml-substituted"
    mv "./depictions/${package}/info.xml-substituted" "./depictions/${package}/info.xml"
    ./debedit "${file}" "Depiction: https://nserrano.now.sh/repo/depictions/?p=${package}"
  fi
done

rm Packages*
./dpkg-scanpackages -m . /dev/null >Packages
bzip2 Packages
