FROM jenkins:alpine
RUN /usr/local/bin/install-plugins.sh \
    git \
    kubernetes-ci \
    ansicolor:0.4.3

#    credentials \
#    display-url-api \
#    workflow-step-api \
#    script-security \
ENV JAVA_OPTS -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Taipei
# COPY config.xml /usr/share/jenkins/ref/config.xml.override
