#!groovy
def podLabel = "${env.JOB_NAME}-${env.BUILD_NUMBER}".replace('/', '-').replace('.', '')

podTemplate(label: podLabel, containers: [
    containerTemplate(name: 'jnlp', image: env.JNLP_SLAVE_IMAGE, args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
    containerTemplate(name: 'kube', image: "${env.PRIVATE_REGISTRY}/library/kubectl:v1.7.2", ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'helm', image: 'henryrao/helm:2.3.1', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'dind', image: 'docker:stable-dind', privileged: true, ttyEnabled: true, command: 'dockerd', 
                      args: '--host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=vfs')
    ],
    volumes: [
        emptyDirVolume(mountPath: '/var/run', memory: false),
        hostPathVolume(mountPath: "/etc/docker/certs.d/${env.PRIVATE_REGISTRY}/ca.crt", hostPath: "/etc/docker/certs.d/${env.PRIVATE_REGISTRY}/ca.crt"),
        hostPathVolume(mountPath: '/home/jenkins/.kube/config', hostPath: '/etc/kubernetes/admin.conf'),
        persistentVolumeClaim(claimName: env.HELM_REPOSITORY, mountPath: '/var/helm/', readOnly: false)
    ]
) {
    node(podLabel) {
        ansiColor('xterm') {
            checkout scm
            
            def head = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
            def jenkinsVer = sh(returnStdout: true, script: 'cat Dockerfile | sed -n \'s/FROM\\s\\+.*jenkins:\\(.*\\)/\\1/p\'').trim()
            def commit_log = sh(script: 'git log --format=%B -n 1', returnStdout: true).trim()
            def image

            stage('build') {
                image = docker.build("${env.PRIVATE_REGISTRY}/jenkins/jenkins", "--no-cache=true --pull .")
            }
            stage('push') {
                docker.withRegistry(env.PRIVATE_REGISTRY_URL, 'docker-login') {
                    image.push("${jenkinsVer}-${head}-${env.BUILD_ID}")
                    image.push('latest')
                }
            }
            stage('package') {
                container('helm') {
                    sh 'helm init --client-only'
                    dir('jenkins') {
                        echo 'update image tag'
                        sh """
                        sed -i \'s/\${BUILD_TAG}/${jenkinsVer}-${head}-${env.BUILD_ID}/\' ./templates/NOTES.txt ./values.yaml
                        """
                        sh 'helm lint .'
                        sh 'helm package --destination /var/helm/repo .'
                    }
                    dir('/var/helm/repo') {
                        def flags = "--url ${env.HELM_PUBLIC_REPO_URL}"
                        flags = fileExists('index.yaml') ? "${flags} --merge index.yaml" : flags
                        sh "helm repo index ${flags} ."
                    }
                }
                build job: 'helm-repository/master', parameters: [string(name: 'commiter', value: "${env.JOB_NAME}\ncommit: ${commit_log}")]
            }

            step([$class: 'LogParserPublisher', failBuildOnError: true, unstableOnWarning: true, showGraphs: true,
                  projectRulePath: 'jenkins-rule-logparser', useProjectRule: true])
        }

    }
}