#!groovy
properties(
    [
        pipelineTriggers([]),
        parameters(
                [
                    string(name: 'imageRepo', defaultValue: 'henryrao/jenkins-kubernetes', description: 'Name of Image'),
                    booleanParam(name: 'deployToProduction', defaultValue: false, description: '')
                ]
        )
    ]
)
podTemplate(label: 'jenkins-kubernetes', containers: [
        containerTemplate(name: 'jnlp', image: 'henryrao/jnlp-slave', args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
        containerTemplate(name: 'kubectl', image: 'henryrao/kubectl:1.5.2', ttyEnabled: true, command: 'cat')
    ],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
                hostPathVolume(mountPath: '/root/.kube/config', hostPath: '/root/.kube/config'),
                persistentVolumeClaim(claimName: 'helm-repository', mountPath: '/var/helm/repo', readOnly: false)
        ]
) {
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
            stage('package') {
                docker.image('henryrao/helm:2.3.1').inside('') { c ->
                    sh '''
                    # packaging
                    helm package --destination /var/helm/repo jenkins
                    helm repo index --url https://grandsys.github.io/helm-repository/ --merge /var/helm/repo/index.yaml /var/helm/repo
                    '''
                }
                build job: 'helm-repository/master', parameters: [string(name: 'commiter', value: "${env.JOB_NAME}\ncommit: ${sh(script: 'git log --format=%B -n 1', returnStdout: true).trim()}")]
            }

            step([$class: 'LogParserPublisher', failBuildOnError: true, unstableOnWarning: true, showGraphs: true,
                  projectRulePath: 'jenkins-rule-logparser', useProjectRule: true])
        }

    }
}