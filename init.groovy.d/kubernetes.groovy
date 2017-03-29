#!groovy
import jenkins.model.Jenkins
import org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud

def env = System.getenv()

def kubernetesCloud = Jenkins.instance.clouds.find { it.getDisplayName() == "kubernetes" }
if (kubernetesCloud == null)
{
  println('--> creating default KubernetesCloud')
  kubernetesCloud = new KubernetesCloud("kubernetes")
  Jenkins.instance.clouds.add(kubernetesCloud)
}
else
{
  println "--> found $kubernetesCloud"
}

kubernetesCloud.setNamespace(env['KUBERNETES_CLOUD_NAMESPACE'] ?: 'default')
kubernetesCloud.setJenkinsUrl(env['KUBERNETES_CLOUD_JENKINS_URL'] ?: 'http://jenkins.default.svc.cluster.local:8080')
kubernetesCloud.setServerUrl(env['KUBERNETES_CLOUD_SERVER'] ?: 'https://kubernetes.default.svc.cluster.local')
kubernetesCloud.setContainerCapStr(env['KUBERNETES_CLOUD_CONTAINER_CAP'] ?: '100')

Jenkins.instance.save()
