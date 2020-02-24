pipeline {
    agent any
    environment {
        DOCKER_REPOSITORY = "10.0.111.123:5000"
        DEV_USERNAME = "ubuntu"
        DEV_HOSTNAME = "10.0.111.106"
    }
    stages {
        stage('build docker image') {
            steps {
                echo 'building'
                sh """
                    docker build . -t gardli/pelican:latest
                    docker tag gardli/pelican ${DOCKER_REPOSITORY}/pelican
                    docker push ${DOCKER_REPOSITORY}/pelican
                """
// this actually works, leaving this here for history
//                script {
//                    docker.withRegistry("http://${DOCKER_REPOSITORY}") {
//                        def myImage = docker.build("pelican:latest")
//                        myImage.push()                    
//                    }
//                }
            }
        } 
        

        stage('STOP docker container on play/DEV') {
            steps {
                echo 'STOPPING on agent machine' 
                sshagent ( ['playground-dev'] ) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${DEV_USERNAME}@${DEV_HOSTNAME} <<EOF
                        uptime && hostname
                        docker container stop pelican || true
                        docker container rm pelican || true
                        sleep 5
                    """
                }
            }
        }
        

        stage('DEPLOY & START docker container to play/DEV') {
            environment {            
                run_params = "-d -p 8000:8000 --name pelican"
            }
            steps {
                echo 'STARTING on agent machine'
                sshagent ( ['playground-dev'] ) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${DEV_USERNAME}@${DEV_HOSTNAME} <<EOF
                        uptime && hostname
                        docker image ls
                        docker pull ${DOCKER_REPOSITORY}/pelican
                        docker container ls
                        docker run ${run_params} ${DOCKER_REPOSITORY}/pelican
                    """
                }
            }
        }
        

        stage('test application on play/DEV') {
            steps {
                echo 'TESTING on agent machine'
                sleep 5
                sh "curl -I http://${DEV_HOSTNAME}:8000"
            }
        }
    }
}