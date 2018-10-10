FROM amitkshirsagar13/k8s-jenkins-plugin
LABEL maintainer="Amit Kshirsagar <amit.kshirsagar.13@gmail.com>"

USER root

RUN mkdir -p /run/secrets
COPY config/users/jenkins-user.yml /run/secrets/jenkins-user.yml
COPY config/users/jenkins-user.json /run/secrets/jenkins-user.json

# # This might cause failure while mounting jenkins_home from hostPath
COPY --chown=jenkins:root config/config.xml /var/jenkins_home/config.xml
COPY --chown=jenkins:root config/scriptApproval.xml /var/jenkins_home/scriptApproval.xml

COPY --chown=jenkins:root config/users/jenkins-user.yml /run/secrets/jenkins-user.yml
COPY --chown=jenkins:root config/users/jenkins-user.json /run/secrets/jenkins-user.json
COPY --chown=jenkins:root config/jobs /var/jenkins_home/jobs

RUN mkdir -p /var/lib/jenkins/init.groovy.d
COPY --chown=jenkins:root config/users/security.simple.groovy /usr/share/jenkins/ref/init.groovy.d/security.simple.groovy
# #COPY config/users/security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy 
# #COPY config/credentials/credentials.groovy /usr/share/jenkins/ref/init.groovy.d/credentials.groovy 
COPY --chown=jenkins:root config/global-tools/jdk-global-tools.groovy /usr/share/jenkins/ref/init.groovy.d/jdk-global-tools.groovy 
COPY --chown=jenkins:root config/global-tools/maven-global-tools.groovy /usr/share/jenkins/ref/init.groovy.d/maven-global-tools.groovy 
COPY --chown=jenkins:root config/kubernetes/kubernetes.groovy /usr/share/jenkins/ref/init.groovy.d/kubernetes.groovy 

RUN chmod 777 -R /run/secrets
RUN chmod 777 -R /var/jenkins_home
USER jenkins


# docker build -t amitkshirsagar13/jenkins-k8s-master .