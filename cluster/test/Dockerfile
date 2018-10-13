FROM busybox

RUN mkdir -p /run/sample
COPY test-deployment.yml /run/sample/deployment.yml
COPY initScript.sh /run/sample/initScript.sh

RUN chmod 777 -R /run/sample
RUN ls -ltrR /run
USER root
