#!/bin/bash

JENKINS_JOBS=${JENKINS_JOBS:-${JENKINS_HOME}/jobs} 

if [ ! -d "$JENKINS_JOBS" ]; then
  echo "$JENKINS_JOBS" not exist 
fi

sudo chown jenkins.jenkins ${JENKINS_JOBS}

/usr/local/bin/jenkins.sh
