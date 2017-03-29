#!groovy
podTemplate(label: 'jenkins-kubernetes', containers: [
        containerTemplate(name: 'jnlp', image: 'henryrao/jnlp-slave', args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
        containerTemplate(name: 'kubectl', image: 'henryrao/kubectl:1.5.2', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'docker', image: 'docker:1.12.6', ttyEnabled: true, command: 'cat')
],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
        ],
        workspaceVolume: emptyDirWorkspaceVolume(false)
) {
    properties([
            pipelineTriggers([]),
            parameters([
                    string(name: 'imageRepo', defaultValue: 'jenkins-kubernetes', description: 'Name of Image' )
            ])
    ])

    node('jenkins-kubernetes') {
        ansiColor('xterm') {
            checkout scm
            def imgSha
            stage('build image') {
                container('docker') {
                    imgSha = sh(returnStdout: true, script: "docker build --pull -q .").trim()[7..-1]
                    echo "${imgSha}"
                }
            }
            stage('push image') {
                container('docker') {
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-login', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                        sh "docker login -u $USERNAME -p $PASSWORD"
                        sh "docker tag ${imgSha} ${params.imageRepo}"
                        sh "docker push ${params.imageRepo}"
                    }
                }
            }
            stage('deploy') {
                container('kubectl') {
                    sh "kubectl apply -f jenkins-deployment.yaml"
                }
            }
            step([$class: 'LogParserPublisher', failBuildOnError: true, unstableOnWarning: true, showGraphs: true,
                  projectRulePath: 'jenkins-rule-logparser', useProjectRule: true])
        }

    }

}