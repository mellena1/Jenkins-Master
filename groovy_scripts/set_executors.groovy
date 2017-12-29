import jenkins.model.Jenkins

Jenkins jenkins = Jenkins.getInstance()

// Set number of executors
jenkins.setNumExecutors(4)

jenkins.save()
