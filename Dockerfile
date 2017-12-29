FROM jenkins/jenkins

# Don't run setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Install extra packages
USER root
RUN apt-get update && apt-get install -y python python-pip
RUN pip install jenkins-job-builder==2.0.0.0b2 python-jenkins

# Install Docker
RUN apt-get -qq update \
   && apt-get -qq -y install \
   curl
RUN curl -sSL https://get.docker.com/ | sh
RUN usermod -a -G staff,docker jenkins

# Install plugins
ADD plugins/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Groovy Scripts stuff
ADD groovy_scripts/* /usr/share/jenkins/ref/init.groovy.d/
