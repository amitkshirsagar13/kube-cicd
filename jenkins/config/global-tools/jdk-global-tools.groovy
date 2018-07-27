import jenkins.model.*
import hudson.model.*
import hudson.tools.*
import groovy.json.JsonSlurperClassic

def onlineGlobalToolList = new URL ("https://raw.githubusercontent.com/amitkshirsagar13/kube-cicd/master/jenkins/config/global-tools/jenkins-global-tools.json").getText()

def globalToolList = new JsonSlurperClassic().parseText(onlineGlobalToolList)

def inst = Jenkins.getInstance()

def desc = inst.getDescriptor("hudson.model.JDK")

def installations = [];

def installer = new JDKInstaller(globalToolList.jdk.version, true)
def installerProps = new InstallSourceProperty([installer])
def installation = new JDK(globalToolList.jdk.name, "", [installerProps])
installations.push(installation)

desc.setInstallations(installations.toArray(new JDK[0]))

desc.save()  