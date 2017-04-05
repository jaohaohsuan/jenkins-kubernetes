#!groovy
podTemplate(label: 'jenkins-kubernetes', containers: [
        containerTemplate(name: 'jnlp', image: 'henryrao/jnlp-slave', args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
        containerTemplate(name: 'kubectl', image: 'henryrao/kubectl:1.5.2', ttyEnabled: true, command: 'cat')
    ],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
        ],
        workspaceVolume: emptyDirWorkspaceVolume(false)
) {
    properties([
            pipelineTriggers([]),
            parameters([
                    string(name: 'imageRepo', defaultValue: 'henryrao/jenkins-kubernetes', description: 'Name of Image'),
                    booleanParam(name: 'deployToProduction', defaultValue: false, description: '')
            ])
    ])

    node('jenkins-kubernetes') {
        ansiColor('xterm') {
            checkout scm
            stage('docker build & push') {

                def jenkinsVer = sh(returnStdout: true, script: 'cat Dockerfile | sed -n \'s/FROM jenkins:\\(.*\\)/\\1/p\'').trim()

                docker.withRegistry('https://registry.hub.docker.com/', 'docker-login') {

                    def image = docker.build("henryrao/jenkins-kubernetes:${jenkinsVer}")

                    image.push()
                    image.push('latest')
                }

            }
            stage('deploy') {
                if (params.deployToProduction) {
                    sh "kubectl apply -f jenkins-deployment.yaml"
                }
            }
            step([$class: 'LogParserPublisher', failBuildOnError: true, unstableOnWarning: true, showGraphs: true,
                  projectRulePath: 'jenkins-rule-logparser', useProjectRule: true])
        }

    }

}