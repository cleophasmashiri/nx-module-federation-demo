pipeline {
    agent any

    environment {
        NX_CLI = 'nx'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'git remote add origin2 https://github.com/cleophasmashiri/nx-module-federation-demo.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    def nodeHome = tool name: 'NodeJS 14', type: 'NodeJSInstallation'
                    env.PATH = "${nodeHome}/bin:${env.PATH}"
                }
                sh 'npm ci'
            }
        }

        stage('Lint') {
            steps {
                script {
                    def apps = sh(script: "${NX_CLI} show projects", returnStdout: true).trim().split('\n')
                    for (app in apps) {
                        sh "${NX_CLI} lint ${app}"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    def apps = sh(script: "${NX_CLI} show projects", returnStdout: true).trim().split('\n')
                    for (app in apps) {
                        sh "${NX_CLI} test ${app}"
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    def apps = sh(script: "${NX_CLI} show projects", returnStdout: true).trim().split('\n')
                    for (app in apps) {
                        sh "${NX_CLI} build ${app}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        def apps = sh(script: "${NX_CLI} show projects", returnStdout: true).trim().split('\n')
                        for (app in apps) {
                            sh "${NX_CLI} deploy ${app}"
                        }
                    } else {
                        echo 'Not deploying as this is not the main branch'
                    }
                }
            }
        }
    }

    post {
        always {
            junit '**/test-results/*.xml'
            archiveArtifacts artifacts: '**/dist/**', allowEmptyArchive: true
            cleanWs()
        }
    }
}
