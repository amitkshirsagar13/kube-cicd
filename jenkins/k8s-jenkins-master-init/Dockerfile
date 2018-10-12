FROM busybox
LABEL maintainer="Amit Kshirsagar <amit.kshirsagar.13@gmail.com>"


COPY --chown=jenkins:root config/config.xml /var/jenkins_home/config.xml
COPY --chown=jenkins:root config/scriptApproval.xml /var/jenkins_home/scriptApproval.xml

COPY --chown=jenkins:root config/com.veracode.jenkins.plugin.VeracodeNotifier.xml /var/jenkins_home/com.veracode.jenkins.plugin.VeracodeNotifier.xml
COPY --chown=jenkins:root config/hudson.plugins.sonar.MsBuildSQRunnerInstallation.xml /var/jenkins_home/hudson.plugins.sonar.MsBuildSQRunnerInstallation.xml
COPY --chown=jenkins:root config/hudson.plugins.sonar.SonarGlobalConfiguration.xml /var/jenkins_home/hudson.plugins.sonar.SonarGlobalConfiguration.xml
COPY --chown=jenkins:root config/hudson.plugins.sonar.SonarRunnerInstallation.xml /var/jenkins_home/hudson.plugins.sonar.SonarRunnerInstallation.xml
COPY --chown=jenkins:root config/jenkins.model.JenkinsLocationConfiguration.xml /var/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml

COPY --chown=jenkins:root config/jobs /var/jenkins_home/jobs



RUN chmod 777 -R /var/jenkins_home