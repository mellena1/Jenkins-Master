#!groovy

import jenkins.model.*
import hudson.security.*
import hudson.model.User
import jenkins.security.s2m.AdminWhitelistRule
import org.apache.commons.lang.RandomStringUtils

def instance = Jenkins.getInstance()

// Make admin user if none has been made yet
if(User.getAll().size() == 0){
    String pass = org.apache.commons.lang.RandomStringUtils.random(32, true, true)
    File adminPassFile = new File("/var/jenkins_home/secrets/initialAdminPassword")
    adminPassFile << (pass + "\n")
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount("admin", pass)
    instance.setSecurityRealm(hudsonRealm)
}


// Disable anonymous read
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// Disable CLI over remoting
jenkins.model.Jenkins.instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Set agent protocols
java.util.Set protocols = ["JNLP4-connect"]
instance.setAgentProtocols(protocols)

instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)
