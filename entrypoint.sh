#!/bin/bash

sudo chown 1000.1000 ${JENKINS_JOBS:-${JENKINS_HOME}/jobs} 

/usr/local/bin/jenkins.sh
