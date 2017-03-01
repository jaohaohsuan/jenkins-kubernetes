FROM jenkins:latest
RUN /usr/local/bin/install-plugins.sh \
    workflow-aggregator:2.4 \
    git \
    kubernetes-ci \
    ansicolor:0.4.3

#    credentials \
#    display-url-api \
#    workflow-step-api \
#    script-security \
ENV JAVA_OPTS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Taipei -Djenkins.install.runSetupWizard=false"
# COPY config.xml /usr/share/jenkins/ref/config.xml.override
COPY basic-security.groovy /usr/share/jenkins/ref/init.groovy.d/basic-security.groovy
