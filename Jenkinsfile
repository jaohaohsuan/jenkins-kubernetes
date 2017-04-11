#!groovy
podTemplate(label: 'jenkins-kubernetes', containers: [
        containerTemplate(name: 'jnlp', image: 'henryrao/jnlp-slave', args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
        containerTemplate(name: 'kubectl', image: 'henryrao/kubectl:1.5.2', ttyEnabled: true, command: 'cat')
    ],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
        ]
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
            def image
            stage('build') {
                image = docker.build("henryrao/jenkins-kubernetes", "--no-cache=true --pull .")
            }
            stage('push') {
                docker.withRegistry('https://registry.hub.docker.com/', 'docker-login') {
                    def jenkinsVer = sh(returnStdout: true, script: 'cat Dockerfile | sed -n \'s/FROM jenkins:\\(.*\\)/\\1/p\'').trim()
                    image.push("$jenkinsVer")
                    image.push('latest')
                }
            }
            stage('deploy') {
                if (params.deployToProduction) {
                    container('kubectl') {
                        sh "kubectl apply -f jenkins-deployment.yaml"
                    }
                }
            }
            step([$class: 'LogParserPublisher', failBuildOnError: true, unstableOnWarning: true, showGraphs: true,
                  projectRulePath: 'jenkins-rule-logparser', useProjectRule: true])
        }

    }

}