import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;
import groovy.json.JsonSlurperClassic

def onlineCredentialList = new URL ("https://raw.githubusercontent.com/amitkshirsagar13/kube-cicd/master/jenkins/config/credentials/jenkins-creds.json").getText()

def credentialList = new JsonSlurperClassic().parseText(onlineCredentialList)

credentialList.credentials.each{
    def id = it.credential.id
    def user = it.credential.user
    def pass = it.credential.password
    def description = it.credential.description

    println "Creating credential " + user + "..."
    Credentials creds = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,id, description, user, pass)

    SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), creds)
    println "Credential " + user	 + " was created"
}