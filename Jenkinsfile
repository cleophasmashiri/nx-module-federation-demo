pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'node:14' // Specify the Docker image you want to use
        NX_CLI = 'nx'
        DOCKER_REGISTRY = 'cleophasmashiri'
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
                            """
                            writeFile file: "Dockerfile.${appName}", text: dockerFileContent
                            def imageName = "${DOCKER_REGISTRY}/${appName}:latest"
                            sh "docker build -t ${imageName} -f Dockerfile.${appName} ."
                            //sh "docker push ${imageName}"
                            withCredentials([string(credentialsId: 'DockerHubPwd', variable: 'dockerpwd')]) {
                                sh "docker push ${imageName}"
                                // sh "docker login -u cleophasmashiri -p ${dockerpwd}"
                            }
                            // steps {
                            //     dockerBuildAndPublish {
                            //         repositoryName(imageName)
                            //         tag('${GIT_REVISION,length=9}')
                            //         registryCredentials('DockerHubPwd')
                            //         forcePull(false)
                            //         forceTag(false)
                            //         createFingerprints(false)
                            //         skipDecorate()
                            //     }
                            // }    
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            when {
                expression { env.BRANCH_NAME == 'main' && env.AFFECTED_APPS }
            }
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