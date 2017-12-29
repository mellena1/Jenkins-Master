from jenkinsapi.jenkins import Jenkins
from jenkinsapi.credential import UsernamePasswordCredential, SSHKeyCredential
from jenkinsapi.credential import AmazonWebServicesCredentials
import os


user = 'automation_user'
password = os.environ['AUTOPASS']

J = Jenkins('http://localhost:8080', username=user, password=password)

creds = J.credentials


def get_key_file(key_file):
    key_file = os.path.expanduser(key_file)
    key = ''
    if not os.path.exists(key_file):
        raise ValueError('File does not exist!!!')
    with open(key_file, 'r') as f:
        for line in f:
            key += line
    return key


####################
#      Github      #
####################
github_desc = 'Github'
github_cred = {
    'credential_id': github_desc,
    'description': github_desc,
    'userName': 'mellena1',
    'password': os.environ['GITAPIKEY']
}
# Don't want to use a try catch but jenkinsapi has a bug in it
creds[github_desc] = UsernamePasswordCredential(github_cred)


#############################
#      automation_user      #
#############################
automation_user_desc = 'jobs'
automation_user_cred = {
    'credential_id': automation_user_desc,
    'description': automation_user_desc,
    'userName': 'automation_user',
    'password': password
}
creds[automation_user_desc] = UsernamePasswordCredential(automation_user_cred)


########################
#      delphi-ssh      #
########################
# Read in key
delphi_key = get_key_file(os.environ['DELPHI_SSH_KEY_FILE'])
# Make creds
delphi_key_desc = 'delphi-ssh'
delphi_key_cred = {
    'credential_id': delphi_key_desc,
    'description': delphi_key_desc,
    'passphrase': '',
    'userName': 'mellena1_',
    'private_key': delphi_key
}
creds[delphi_key_desc] = SSHKeyCredential(delphi_key_cred)

########################
#       AWS-ssh        #
########################
# Read in key
aws_key = get_key_file(os.environ['AWS_SSH_KEY_FILE'])
# Make creds
aws_key_desc = 'mellena1-aws-ssh'
aws_key_cred = {
    'credential_id': aws_key_desc,
    'description': aws_key_desc,
    'passphrase': '',
    'userName': 'ubuntu',
    'private_key': aws_key
}
creds[aws_key_desc] = SSHKeyCredential(aws_key_cred)

#############################
#        AWS Creds          #
#############################
aws_creds_id = 'aws-creds'
aws_creds_desc = 'aws creds for my account'
aws_creds_cred = {
    'credential_id': aws_creds_id,
    'description': aws_creds_desc,
    'accessKey': os.environ['AWS_ACCESS'],
    'secretKey': os.environ['AWS_SECRET']
}
try:
    creds[aws_creds_id] = AmazonWebServicesCredentials(aws_creds_cred)
except:
    print('AWS cred creation might have failed for some reason???')
