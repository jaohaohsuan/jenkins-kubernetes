FROM jenkins:latest
RUN /usr/local/bin/install-plugins.sh \
    workflow-aggregator \
    docker-workflow \
    kubernetes \
    workflow-durable-task-step \
    script-security \
    ansicolor \
    blueocean \
    log-parser \
    git \
    ansible

ENV JAVA_OPTS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Taipei -Djenkins.install.runSetupWizard=false"

COPY init.groovy.d /usr/share/jenkins/ref/init.groovy.d
# COPY plugins/*.hpi /usr/share/jenkins/ref/plugins/

# VOLUME ["/var/jenkins_home/plugins"]


USER root

RUN apt-get update && apt-get install -y \
    docker \
    ansible \
  && rm -rf /var/lib/apt/lists/*

USER jenkins
