#!groovy
podTemplate(label: 'jenkins-kubernetes', containers: [
        containerTemplate(name: 'jnlp', image: 'henryrao/jnlp-slave', args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
        containerTemplate(name: 'kubectl', image: 'henryrao/kubectl:1.5.2', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'docker', image: 'docker:1.12.6', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'ansible', image: 'alpine:edge', ttyEnabled: true, command: 'cat')
],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
        ],
        workspaceVolume: emptyDirWorkspaceVolume(false)
) {
    properties([
            pipelineTriggers([]),
            parameters([
                    string(name: 'imageRepo', defaultValue: 'henryrao/jenkins-kubernetes', description: 'Name of Image' )
            ])
    ])

    node('jenkins-kubernetes') {
        ansiColor('xterm') {
            checkout scm
            stage('docker build & push') {

                def image = docker.build "${params.imageRepo}:latest"

                docker.withRegistry('https://registry-1.docker.io/v2', 'docker-login') {
                    image.push()
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