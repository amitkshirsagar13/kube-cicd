FROM busybox
LABEL maintainer="Amit Kshirsagar <amit.kshirsagar.13@gmail.com>"

RUN mkdir -p /run/jenkins_home

COPY --chown=root:root config/config.xml /run/jenkins_home/config.xml
COPY --chown=root:root config/scriptApproval.xml /run/jenkins_home/scriptApproval.xml

COPY --chown=root:root config/com.veracode.jenkins.plugin.VeracodeNotifier.xml /run/jenkins_home/com.veracode.jenkins.plugin.VeracodeNotifier.xml
COPY --chown=root:root config/hudson.plugins.sonar.MsBuildSQRunnerInstallation.xml /run/jenkins_home/hudson.plugins.sonar.MsBuildSQRunnerInstallation.xml
COPY --chown=root:root config/hudson.plugins.sonar.SonarGlobalConfiguration.xml /run/jenkins_home/hudson.plugins.sonar.SonarGlobalConfiguration.xml
COPY --chown=root:root config/hudson.plugins.sonar.SonarRunnerInstallation.xml /run/jenkins_home/hudson.plugins.sonar.SonarRunnerInstallation.xml
COPY --chown=root:root config/jenkins.model.JenkinsLocationConfiguration.xml /run/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml

COPY --chown=root:root config/jobs /run/jenkins_home/jobs

RUN chmod 777 -R /var/jenkins_home