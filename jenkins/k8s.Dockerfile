FROM amitkshirsagar13/jenkins-k8s-plugins as jenkins-k8s
MAINTAINER Amit Kshirsagar <amit.kshirsagar.13@gmail.com>

USER root

RUN mkdir -p /run/secrets
COPY config/users/jenkins-user.yml /run/secrets/jenkins-user.yml
COPY config/users/jenkins-user.json /run/secrets/jenkins-user.json
COPY config/config.xml /run/secrets/config.xml

RUN mkdir -p /var/lib/jenkins/init.groovy.d
COPY config/users/security.simple.groovy /usr/share/jenkins/ref/init.groovy.d/security.simple.groovy
COPY config/users/security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy 
COPY config/credentials/credentials.groovy /usr/share/jenkins/ref/init.groovy.d/credentials.groovy 
COPY config/global-tools/jdk-global-tools.groovy /usr/share/jenkins/ref/init.groovy.d/jdk-global-tools.groovy 
COPY config/global-tools/maven-global-tools.groovy /usr/share/jenkins/ref/init.groovy.d/maven-global-tools.groovy 
COPY config/kubernetes/kubernetes.groovy /usr/share/jenkins/ref/init.groovy.d/kubernetes.groovy 

RUN chmod 777 -R /run/secrets
RUN chmod 777 -R /var/jenkins_home
USER jenkins

# docker build -t amitkshirsagar13/jenkins-k8s .