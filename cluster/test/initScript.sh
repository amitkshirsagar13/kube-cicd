#!/bin/bash
whoami
pwd
env
ls -ltrR /data/
ls -ltrR /run/
mkdir /run/temp
cp -R /run/sample/* /run/temp/
cp -R /run/sample/* /data/init
ls -ltrR /run/temp/
ls -ltrR /data/
