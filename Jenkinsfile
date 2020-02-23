pipeline {
    agent any
    environment {
        DOCKER_REPOSITORY = "3.123.153.93:5000"
        USERNAME = "ubuntu"
        HOSTNAME = "18.197.11.62"
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
                sh """
                    docker build . -t gardli/pelican:latest
                    docker image tag gardli/pelican ${DOCKER_REPOSITORY}/pelican
                    docker push http://${DOCKER_REPOSITORY}/pelican
                """
            }
        } 
        stage('deploy docker container to play/dev') {
            steps {
                echo 'STOPPING on agent machine' 
                sshagent(credentials : ['playground-dev']) {
                    sh "ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTNAME} uptime"
                    sh 'docker container stop pelican || true'
                    sh 'docker container rm pelican || true'
                    sleep 3
                }

                echo 'STARTING on agent machine'
                sshagent(credentials : ['playground-dev']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${USERNAME}@${HOSTNAME} uptime"
                        docker pull http://${DOCKER_REPOSITORY}:5000/pelican
                        docker run -d -p 8000:8000 --name pelican ${DOCKER_REPOSITORY}/pelican
                    """
                }
            }
        }
        stage('test application on play/dev') { 
            steps {
                echo 'TESTING on agent machine'
                sleep 3
                sh "curl -I http://${HOSTNAME}:8000"
            }
        }
    }
}