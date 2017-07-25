#!groovy
podTemplate(label: 'jenkins-kubernetes', containers: [
        containerTemplate(name: 'jnlp', image: env.JNLP_SLAVE_IMAGE, args: '${computer.jnlpmac} ${computer.name}', alwaysPullImage: true),
        containerTemplate(name: 'helm', image: 'henryrao/helm:2.3.1', ttyEnabled: true, command: 'cat'),
        containerTemplate(name: 'kubectl', image: 'henryrao/kubectl:1.5.2', ttyEnabled: true, command: 'cat')
    ],
        volumes: [
                hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
                hostPathVolume(mountPath: '/root/.kube/config', hostPath: '/home/jenkins/.kube/config'),
                persistentVolumeClaim(claimName: env.HELM_REPOSITORY, mountPath: '/var/helm/', readOnly: false)
        ]
) {
    node('jenkins-kubernetes') {
        ansiColor('xterm') {
            checkout scm
            
            def head = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
            def jenkinsVer = sh(returnStdout: true, script: 'cat Dockerfile | sed -n \'s/FROM\\s\\+.*jenkins:\\(.*\\)/\\1/p\'').trim()

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
                sh """
                echo 'update image tag'
                sed -i \'s/\${BUILD_TAG}/${jenkinsVer}-${head}-${env.BUILD_ID}/\' jenkins/templates/NOTES.txt jenkins/values.yaml
                """
                container('helm') {
                    sh 'helm init --client-only'
                    sh 'helm package --destination /var/helm/repo jenkins'
                    sh """
                    merge=`[[ -e '/var/helm/repo/index.yaml' ]] && echo '--merge /var/helm/repo/index.yaml' || echo ''`
                    helm repo index --url ${env.HELM_PUBLIC_REPO_URL} \$merge /var/helm/repo
                    """
                }
                build job: 'helm-repository/master', parameters: [string(name: 'commiter', value: "${env.JOB_NAME}\ncommit: ${sh(script: 'git log --format=%B -n 1', returnStdout: true).trim()}")]
            }

            step([$class: 'LogParserPublisher', failBuildOnError: true, unstableOnWarning: true, showGraphs: true,
                  projectRulePath: 'jenkins-rule-logparser', useProjectRule: true])
        }

    }
}