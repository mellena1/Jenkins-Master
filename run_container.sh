#!/bin/bash
rm -rf ~/docker/jenkins
mkdir -p ~/docker/jenkins
docker run -p 8080:8080 -d -v ~/docker/jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock my-jenkins/jenkins

#########################
#     Ask for Inputs    #
#########################
# mellena1
read -s -p "Enter mellena1 password: " MYPASS
echo ""
# Github creds
read -s -p "Enter Github API token for mellena1: " GITAPIKEY
export GITAPIKEY=$GITAPIKEY
echo ""
# Delphi ssh
read -e -p "Enter location of delphi ssh key file: " DELPHI_SSH_KEY_FILE
export DELPHI_SSH_KEY_FILE=$DELPHI_SSH_KEY_FILE
# AWS ssh key
read -e -p "Enter location of AWS ssh key file: " AWS_SSH_KEY_FILE
export AWS_SSH_KEY_FILE=$AWS_SSH_KEY_FILE
# AWS Access Key
if [ ! -z $AWS_ACCESS_KEY_ID ]
then
    export AWS_ACCESS=$AWS_ACCESS_KEY_ID
else
    read -s -p "Enter AWS_ACCESS_KEY_ID: " AWS_ACCESS
    export AWS_ACCESS=$AWS_ACCESS
fi
# AWS Secret Key
if [ ! -z $AWS_SECRET_ACCESS_KEY ]
then
    export AWS_SECRET=$AWS_SECRET_ACCESS_KEY
else
    read -s -p "Enter AWS_SECRET_ACCESS_KEY: " AWS_SECRET
    export AWS_SECRET=$AWS_SECRET
fi

# Wait for jenkins to come up
echo "Waiting for jenkins to come up..."
until curl -sSf http://localhost:8080/login?from=%2F > /dev/null 2>&1
do
    sleep 2
done
# Sleep 5 more seconds just to make sure its good
sleep 5
echo "Jenkins up at http://localhost:8080"

############################
#      Send to Jenkins     #
############################
# Get admin password
ADMIN_PASSWORD=`cat ~/docker/jenkins/secrets/initialAdminPassword`
# Get Jenkins-CLI
curl http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar > /dev/null 2>&1
# mellena1 account
echo "Making mellena1 user..."
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"mellena1\", \"$MYPASS\")" | java -jar jenkins-cli.jar -auth admin:$ADMIN_PASSWORD -s http://localhost:8080/ groovy =
# automation_user account
echo "Making automation_user..."
export AUTOPASS=`openssl rand -base64 32`
echo "jenkins.model.Jenkins.instance.securityRealm.createAccount(\"automation_user\", \"$AUTOPASS\")" | java -jar jenkins-cli.jar -auth admin:$ADMIN_PASSWORD -s http://localhost:8080/ groovy =
# Don't need initialAdminPassword file anymore
rm ~/docker/jenkins/secrets/initialAdminPassword
# Don't need Jenkins-CLI.jar anymore
rm jenkins-cli.jar
# Credentials
echo "Making credentials..."
pip install jenkinsapi > /dev/null
python python_scripts/make_credentials.py
# Make job builder job
echo "Making Job Builder Job..."
pip install jenkins-job-builder==2.0.0.0b2 > /dev/null
jenkins-jobs --user admin --password $ADMIN_PASSWORD --conf job_builder/jenkins_jobs.conf update job_builder/Job-Builder-Job.yml > /dev/null 2>&1
# Run that job
echo "Running the job so all other jobs will be created..."
python python_scripts/run_job_builder_job.py
echo "Done."
