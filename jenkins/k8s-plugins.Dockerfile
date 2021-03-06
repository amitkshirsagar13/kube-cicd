FROM jenkins/jenkins:lts-alpine
LABEL maintainer="Amit Kshirsagar <amit.kshirsagar.13@gmail.com>"

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=300"
ENV CURL_CONNECTION_TIMEOUT=30
ENV CURL_RETRY=2
USER root

COPY config/plugins/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN cat /usr/share/jenkins/ref/plugins.txt | /usr/local/bin/install-plugins.sh 
