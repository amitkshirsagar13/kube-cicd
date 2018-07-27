#!groovy


import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
import groovy.json.JsonSlurperClassic

def instance = Jenkins.getInstance()

String fileContents = new File('/run/secrets/jenkins-user.yml').text

println "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
println fileContents
println "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"


def onlineUserList = new URL ("https://raw.githubusercontent.com/amitkshirsagar13/kube-cicd/master/jenkins/config/users/jenkins-user.json").getText()

def jsonUserList = new File('/run/secrets/jenkins-user.json')

def userList = new JsonSlurperClassic().parseText(onlineUserList)

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

userList.users.each{
    def user = it.user.name
    def pass = it.user.password
    println "Creating user " + user + "..."
    hudsonRealm.createAccount(user, pass)

    println "Security User " + user	 + " was created"
}
instance.setSecurityRealm(hudsonRealm)

    
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)