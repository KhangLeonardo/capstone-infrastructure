#!/bin/bash

# Set hostname
sudo hostnamectl set-hostname jenkins-server

# Install dependencies
sudo yum install fontconfig java jq -y

# Install Java 17
sudo wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
sudo yum -y install ./jdk-17_linux-x64_bin.rpm

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install jenkins -y

# Start Jenkins to generate initial admin password
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 30

# Disable Jenkins setup wizard in /etc/sysconfig/jenkins
echo 'JAVA_ARGS="-Djenkins.install.runSetupWizard=false"' | sudo tee -a /etc/sysconfig/jenkins

# Install and configure Jenkins Configuration as Code (JCasC)
sudo mkdir -p /var/lib/jenkins/casc_configs
sudo tee /var/lib/jenkins/casc_configs/jenkins.yaml <<EOL
jenkins:
  systemMessage: "Configured automatically by script"
  disableAdminSecurity: true
EOL

# Create groovy script for basic security
sudo mkdir -p /var/lib/jenkins/init.groovy.d/
cat <<EOF | sudo tee /var/lib/jenkins/init.groovy.d/basic-security.groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin','s3cr3t!')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF

# Make sure the script is executable
sudo chmod 0777 /var/lib/jenkins/init.groovy.d/basic-security.groovy

# Restart Jenkins service to apply security changes
sudo systemctl restart jenkins
sleep 30

# Download Jenkins CLI
sudo wget -O /usr/local/bin/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar

# Install desired plugins
declare -a PluginList=("apache-httpcomponents-client-4-api" "authentication-tokens" "blueocean-bitbucket-pipeline" "blueocean-commons" "blueocean-config" "blueocean-core-js" "blueocean-dashboard" "blueocean-display-url" "blueocean-events" "blueocean-git-pipeline" "blueocean-github-pipeline" "blueocean-i18n" "blueocean-jwt" "blueocean-personalization" "blueocean-pipeline-api-impl" "blueocean-pipeline-editor" "blueocean-pipeline-scm-api" "blueocean-rest-impl" "blueocean-rest" "blueocean-web" "bootstrap5-api" "bouncycastle-api" "branch-api" "caffeine-api" "checks-api" "cloudbees-bitbucket-branch-source" "cloudbees-folder" "commons-lang3-api" "commons-text-api" "credentials-binding" "credentials" "dark-theme" "display-url-api" "durable-task" "echarts-api" "favorite" "font-awesome-api" "git-client" "git" "gitea" "github-api" "github-branch-source" "github" "gson-api" "handy-uri-templates-2-api" "htmlpublisher" "instance-identity" "ionicons-api" "jackson2-api" "jakarta-activation-api" "jakarta-mail-api" "javax-activation-api" "javax-mail-api" "jaxb" "jenkins-design-language" "jjwt-api" "joda-time-api" "jquery3-api" "json-path-api" "junit" "kubernetes-client-api" "kubernetes-credentials" "kubernetes" "mailer" "matrix-project" "metrics" "mina-sshd-api-common" "mina-sshd-api-core" "okhttp-api" "pipeline-build-step" "pipeline-graph-analysis" "pipeline-groovy-lib" "pipeline-input-step" "pipeline-milestone-step" "pipeline-model-api" "pipeline-model-definition" "pipeline-model-extensions" "pipeline-stage-step" "pipeline-stage-tags-metadata" "pipeline-stage-view" "plain-credentials" "plugin-util-api" "pubsub-light" "scm-api" "script-security" "snakeyaml-api" "sse-gateway" "ssh-credentials" "structs" "token-macro" "trilead-api" "variant" "workflow-api" "workflow-basic-steps" "workflow-cps" "workflow-durable-task-step" "workflow-job" "workflow-multibranch" "workflow-scm-step" "workflow-step-api" "workflow-support" "antisamy-markup-formatter" "build-timeout" "timestamper" "resource-disposer" "ws-cleanup" "ant" "gradle" "workflow-aggregator" "pipeline-github-lib" "pipeline-rest-api" "pipeline-stage-view" "ssh-slaves" "matrix-auth" "pam-auth" "ldap" "email-ext" "dashboard-view")

for plugin in "${PluginList[@]}"; do
    sudo java -jar /usr/local/bin/jenkins-cli.jar -auth admin:s3cr3t! -s http://localhost:8080/ install-plugin "$plugin"
done

# Install Docker
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker jenkins
sudo chkconfig docker on

# Restart Jenkins service to apply plugin changes
sudo systemctl restart jenkins

# Install Docker Compose 
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create a Jenkins job configuration file
cat <<EOF | sudo tee /var/lib/jenkins/job_config.xml
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>Sample Pipeline job</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.90">
    <script>
pipeline {
    agent any
    
    stages {
        stage('Check for .env file update') {
            steps {
                script {
                    def currentEnvChecksum = sh(script: "md5sum ~/.env | cut -d ' ' -f1", returnStdout: true).trim()
                    def s3EnvChecksum = sh(script: "aws s3api head-object --bucket capstone-aws-mykidz-dev-jenkins-server-resource --key .env | jq -r '.Metadata.md5'", returnStdout: true).trim()
                    
                    if (currentEnvChecksum != s3EnvChecksum) {
                        echo "The .env file has been updated. Downloading..."
                        sh "aws s3 cp s3://capstone-aws-mykidz-dev-jenkins-server-resource/.env ~/.env"
                    } else {
                        echo "The .env file is already up to date."
                    }
                }
            }
        }

        stage('Check for docker-compose.yaml update') {
            steps {
                script {
                    def currentComposeChecksum = sh(script: "md5sum ~/docker-compose.yaml | cut -d ' ' -f1", returnStdout: true).trim()
                    def s3ComposeChecksum = sh(script: "aws s3api head-object --bucket capstone-aws-mykidz-dev-jenkins-server-resource --key docker-compose.yaml | jq -r '.Metadata.md5'", returnStdout: true).trim()
                    
                    if (currentComposeChecksum != s3ComposeChecksum) {
                        echo "The docker-compose.yaml file has been updated. Downloading..."
                        sh "aws s3 cp s3://capstone-aws-mykidz-dev-jenkins-server-resource/docker-compose.yaml ~/docker-compose.yaml"
                    } else {
                        echo "The docker-compose.yaml file is already up to date."
                    }
                }
            }
        }
        
        stage('Run Docker Compose') {
            steps {
                echo "Running Docker Compose..."
                // Run docker-compose regardless of updates
                sh "docker-compose up -d"
            }
        }
    }
}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

# Create the Jenkins job using the Jenkins CLI
sudo java -jar /usr/local/bin/jenkins-cli.jar -auth admin:s3cr3t! -s http://localhost:8080/ create-job capstone-deployment < /var/lib/jenkins/job_config.xml
