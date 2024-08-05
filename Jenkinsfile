pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'node:14' // Specify the Docker image you want to use
        NX_CLI = 'nx'
        DOCKER_REGISTRY = 'https://index.docker.io/v1/'
        DOCKER_CREDENTIALS_ID = 'DockerHubPwd'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/cleophasmashiri/nx-module-federation-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('my-mfe-nx-image')
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    docker.image('my-mfe-nx-image').inside {
                        sh 'npm install --force'
                    }
                }
            }
        }

        stage('Get Affected Apps') {
            steps {
                script {
                    def affectedApps = docker.image('my-mfe-nx-image').inside {
                        sh(script: "${NX_CLI} affected:apps --plain", returnStdout: true).trim()
                    }
                    if (affectedApps) {
                        env.AFFECTED_APPS = affectedApps
                    } else {
                        echo "No affected apps detected, defaulting to all apps"
                        // def allApps = docker.image('my-mfe-nx-image').inside {
                        //     sh(script: "${NX_CLI} print-affected --target=build --plain", returnStdout: true).trim()
                        // }
                        def allApps = "shell\nmfe1"
                        env.AFFECTED_APPS = allApps
                        affectedApps = allApps
                    }
                    for (app in affectedApps) {
                        echo "Affect app:" + app
                    }
                    if (!affectedApps) {
                        echo "no apps ui"
                    }
                }
            }
        }

        // stage('Lint') {
        //     when {
        //         expression { env.AFFECTED_APPS }
        //     }
        //     steps {
        //         script {
        //             docker.image('my-mfe-nx-image').inside {
        //                 def apps = env.AFFECTED_APPS.split('\n')
        //                 for (app in apps) {
        //                     sh "${NX_CLI} lint ${app}"
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('Test') {
        //     when {
        //         expression { env.AFFECTED_APPS }
        //     }
        //     steps {
        //         script {
        //             docker.image('my-mfe-nx-image').inside {
        //                 def apps = env.AFFECTED_APPS.split('\n')
        //                 for (app in apps) {
        //                     sh "${NX_CLI} test ${app}"
        //                 }
        //             }
        //         }
        //     }
        // }

        stage('Build') {
            when {
                expression { env.AFFECTED_APPS }
            }
            steps {
                script { 
                    docker.image('my-mfe-nx-image').inside {
                        def apps = env.AFFECTED_APPS.split('\n')
                        for (app in apps) {
                            sh "${NX_CLI} build ${app}"
                        }
                    }
                }
            }
        }

        stage('Build Docker Images for Nginx') {
            when {
                expression { env.AFFECTED_APPS }
            }
            steps {
                script {
                    docker.image('my-mfe-nx-image').inside {
                        def apps = env.AFFECTED_APPS.split('\n')
                        for (app in apps) {
                            def appName = app.split(':')[0]
                            def appDist = "dist/apps/${appName}"
                            def dockerFileContent = """
                            FROM nginx:alpine
                            COPY ${appDist} /usr/share/nginx/html
                            EXPOSE 3000
                            CMD ["nginx", "-g", "daemon off;"]
                            """
                            writeFile file: "Dockerfile.${appName}", text: dockerFileContent
                            def imageName = "cleophasmashiri/${appName}:latest"
                            sh "docker build -t ${imageName} -f Dockerfile.${appName} ."
                
                            docker.withRegistry("${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {docker.image("${imageName}").push()}   
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            // when {
            //     expression { env.BRANCH_NAME == 'master' && env.AFFECTED_APPS }
            // }
            steps {
                script {
                    docker.image('my-mfe-nx-image').inside {
                        def apps = env.AFFECTED_APPS.split('\n')
                        for (app in apps) {
                            def imageName = "${DOCKER_REGISTRY}/${app}:latest"
                            // Here you would add the script to deploy the Docker images to your servers
                            sh "deploy_script.sh ${imageName}"
                        }
                    }
                }
            }
        }
    }

    // post {
    //     always {
    //         docker.image('my-mfe-nx-image').inside {
    //             junit '**/test-results/*.xml'
    //             archiveArtifacts artifacts: '**/dist/**', allowEmptyArchive: true
    //             cleanWs()
    //         }
    //     }
    // }
}