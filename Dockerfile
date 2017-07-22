FROM jenkins/jenkins:2.60.2-alpine
RUN /usr/local/bin/install-plugins.sh \
    workflow-aggregator \
    docker-workflow:1.12 \
    workflow-job:2.12.1 \
    blueocean:1.1.4 \
    kubernetes \
    workflow-durable-task-step \
    script-security \
    ansicolor \
    log-parser \
    git \
    ansible \
    http_request \
    cucumber-testresult-plugin \
    job-dsl \
    authorize-project

ENV JAVA_OPTS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Taipei -Djenkins.install.runSetupWizard=false"

COPY init.groovy.d /usr/share/jenkins/ref/init.groovy.d
ADD jenkins.CLI.xml $JENKINS_HOME
ADD javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration.xml $JENKINS_HOME

USER root
RUN apk --no-cache add sudo
COPY sudoers.d /etc/sudoers.d
COPY entrypoint.sh /entrypoint.sh

RUN sudo chown -R jenkins "$JENKINS_HOME" /usr/share/jenkins/ref

USER jenkins
ENTRYPOINT ["/bin/tini","--","/entrypoint.sh"]

