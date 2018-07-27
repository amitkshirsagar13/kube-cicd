import hudson.tasks.Maven.MavenInstallation;
import hudson.tools.InstallSourceProperty;
import hudson.tools.ToolProperty;
import hudson.tools.ToolPropertyDescriptor;
import hudson.util.DescribableList;
import groovy.json.JsonSlurperClassic

def onlineGlobalToolList = new URL ("https://raw.githubusercontent.com/amitkshirsagar13/kube-cicd/master/jenkins/config/global-tools/jenkins-global-tools.json").getText()

def globalToolList = new JsonSlurperClassic().parseText(onlineGlobalToolList)


def mavenDesc = jenkins.model.Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0]



def isp = new InstallSourceProperty()
def mavenInstaller = new hudson.tasks.Maven.MavenInstaller(globalToolList.maven.version)
isp.installers.add(mavenInstaller)

def proplist = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
proplist.add(isp)

def mavenInstallation = new MavenInstallation(globalToolList.maven.name, "", proplist)

mavenDesc.setInstallations(mavenInstallation)
mavenDesc.save()