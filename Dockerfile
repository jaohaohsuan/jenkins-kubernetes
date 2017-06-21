FROM jenkins:2.46.3-alpine
RUN /usr/local/bin/install-plugins.sh \
    workflow-aggregator \
    docker-workflow:1.12 \
    workflow-job:2.11.1 \
    blueocean:1.1.2 \
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
