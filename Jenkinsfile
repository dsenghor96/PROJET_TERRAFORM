pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "dieys"
        BACKEND_IMAGE = "${DOCKERHUB_USER}/portfolio-api:${BUILD_NUMBER}"
        KUBECONFIG = "/var/jenkins_home/.kube/config"
	FRONTEND_IMAGE = "${DOCKERHUB_USER}/portfolio-react:${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        rm -rf .scannerwork

                        docker run --rm \
                        --network portfolio_perso_portfolio-network \
                        --volumes-from portfolio_jenkins \
                        -w "${WORKSPACE}" \
                        sonarsource/sonar-scanner-cli \
                        -Dsonar.host.url="$SONAR_HOST_URL" \
                        -Dsonar.login="$SONAR_AUTH_TOKEN" \
                        -Dsonar.projectKey=portfolio-mern \
                        -Dsonar.projectName='Portfolio MERN' \
                        -Dsonar.sources=api,ux_react/src \
                        -Dsonar.exclusions=**/node_modules/**,**/.git/**,**/dist/** \
                        -Dsonar.qualitygate.wait=true
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Backend') {
                    steps {
                        sh "docker build -t ${BACKEND_IMAGE} ./api"
                    }
                }

                stage('Frontend') {
                    steps {
                        sh "docker build -t ${FRONTEND_IMAGE} ./ux_react"
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        docker push "$BACKEND_IMAGE"
                        docker push "$FRONTEND_IMAGE"

                        docker tag "$BACKEND_IMAGE" "${DOCKERHUB_USER}/portfolio-api:latest"
                        docker tag "$FRONTEND_IMAGE" "${DOCKERHUB_USER}/portfolio-react:latest"
                        docker push "${DOCKERHUB_USER}/portfolio-api:latest"
                        docker push "${DOCKERHUB_USER}/portfolio-react:latest"
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
 	   steps {
        	sh '''
            	    kubectl apply -f k8s/configmap/app-configmap.yaml
            	    kubectl apply -f k8s/secret/app-secret.yaml
            	    kubectl apply -f k8s/mongodb/statefulset.yaml
            	    kubectl apply -f k8s/mongodb/service.yaml
            	    kubectl apply -f k8s/backend/deployment.yaml
            	    kubectl apply -f k8s/backend/service.yaml
            	    kubectl apply -f k8s/frontend/deployment.yaml
            	    kubectl apply -f k8s/frontend/service.yaml
            	    kubectl apply -f k8s/ingress/ingress.yaml
            	    kubectl rollout restart deployment backend
            	    kubectl rollout restart deployment frontend
            	    kubectl rollout status deployment backend
            	    kubectl rollout status deployment frontend
        	'''
    	     }
	}		
    }

    post {
        success {
            echo "Pipeline execute avec succes"

            emailext(
                subject: "Jenkins - Build #${BUILD_NUMBER} reussi",
                body: """
                    Bonjour Dieynaba,

                    Le pipeline ${JOB_NAME} a ete execute avec succes.

                    Details :
                    - Build  : #${BUILD_NUMBER}
                    - Branche: ${GIT_BRANCH}
                    - Commit : ${GIT_COMMIT}
                    - Duree  : ${currentBuild.durationString}

                    Logs : ${BUILD_URL}
                """,
                to: 'dsenghor96@gmail.com'
            )
        }

        failure {
            echo "Pipeline echoue. Verifie les logs Jenkins."

            emailext(
                subject: "Jenkins - Build #${BUILD_NUMBER} echoue",
                body: """
                    Bonjour Dieynaba,

                    Le pipeline ${JOB_NAME} a echoue.

                    Details :
                    - Build  : #${BUILD_NUMBER}
                    - Branche: ${GIT_BRANCH}
                    - Commit : ${GIT_COMMIT}

                    Logs : ${BUILD_URL}
                """,
                to: 'dsenghor96@gmail.com'
            )
        }

        always {
            sh "docker logout || true"
            echo "Deconnectee de DockerHub"
        }
    }
}
