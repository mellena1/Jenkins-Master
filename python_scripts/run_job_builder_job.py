from jenkinsapi.jenkins import Jenkins
import os


user = 'automation_user'
password = os.environ['AUTOPASS']

J = Jenkins('http://localhost:8080', username=user, password=password)

J.build_job('Jenkins-Jobs')
