FROM jenkins:2.46.2-alpine
RUN /usr/local/bin/install-plugins.sh \
    workflow-aggregator \
    docker-workflow:1.11 \
    workflow-job:2.11
    blueocean:1.0.1 \
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
