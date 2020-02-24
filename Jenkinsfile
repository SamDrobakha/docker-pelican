pipeline {
    agent any
    environment {
        DOCKER_REPOSITORY = "10.0.111.123:5000"
        USERNAME = "ubuntu"
        DEV_HOSTNAME = "10.0.111.106"
}

/*TODO
1. parameter - credentials (key) for agent connection
2. environment set hostname parameter (local) (with aim to have different envs)
3. enviroment docker registry parameter (global)
*/

    stages {
        stage('build docker image') {
            steps {
                echo 'building'
                script {
                    docker.withRegistry("http://${DOCKER_REPOSITORY}") {
                        def myImage = docker.build("pelican:latest")
                        myImage.push()                    
                    }
                }
            }
        } 
        stage('deploy docker container to play/dev') {
            steps {
                echo 'STOPPING on agent machine' 
                sshagent ( ['playground-dev'] ) {
                    sh "ssh -o StrictHostKeyChecking=no ${USERNAME}@${DEV_HOSTNAME} uptime"
                    sh 'docker container stop pelican || true'
                    sh 'docker container rm pelican || true'
                    sleep 5
                }

                echo 'STARTING on agent machine'
                sshagent ( ['playground-dev'] ) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${USERNAME}@${DEV_HOSTNAME} 
                        uptime
                        docker image ls
                        docker pull ${DOCKER_REPOSITORY}/pelican
                        docker container ls
                        docker run -d -p 8000:8000 --name pelican ${DOCKER_REPOSITORY}/pelican
                    """
                }
            }
        }
        stage('test application on play/dev') { 
            steps {
                echo 'TESTING on agent machine'
                sleep 5
                sh "curl -I http://${DEV_HOSTNAME}:8000"
            }
        }
    }
}