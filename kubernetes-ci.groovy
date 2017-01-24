#!groovy
import com.elasticbox.jenkins.k8s.plugin.clouds.*
import org.apache.commons.lang.StringUtils
import org.apache.commons.io.IOUtils
import java.util.Collections
import java.util.List

final String podYaml = IOUtils.toString(new FileInputStream(new File
            ("/var/jenkins_home/sbt-jnlp-slave" + ".yaml")))

PodSlaveConfig sbtPodSlaveConfig = new PodSlaveConfig("sbt-jnlp-slave.yaml","Sbt JNLP Slave", podYaml, "sbt")

List<PodSlaveConfig> podSlaveConfigurations = new ArrayList<>()
podSlaveConfigurations.add(sbtPodSlaveConfig)

KubernetesCloud inulabCloud = new KubernetesCloud("inulab","iNu-Lab","https://10.96.0.1:443","default", "30", "KubeServiceToken", StringUtils.EMPTY,Collections.EMPTY_LIST, podSlaveConfigurations)

Jenkins.instance.clouds.replace(inulabCloud)
Jenkins.instance.save()
