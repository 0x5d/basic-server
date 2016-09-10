IMAGE_NAME=<image name>
docker build -t ${IMAGE_NAME} .

# Get the repo's URI
ECR_URI=$(aws ecr describe-repositories --repository-names <repository name> | grep Uri | awk '{print $2}' | tr -d '"')

# Log in with Docker
$(aws ecr get-login --region us-east-1)
docker tag ${IMAGE_NAME}:latest ${ECR_URI}:${BUILD_NUMBER}
docker push ${ECR_URI}:${BUILD_NUMBER}

# Create new task definition with new tag.
CONTAINER_NAME=<container name>
sed -e "s;%TAG%;"${BUILD_NUMBER}";g" infrastructure/task-definition.json > task-definition-${BUILD_NUMBER}.json
sed -i -e "s;%REPOSITORY_URI%;"${ECR_URI}";g" task-definition-${BUILD_NUMBER}.json
sed -i -e "s;%NAME%;"${CONTAINER_NAME}";g" task-definition-${BUILD_NUMBER}.json

# Register a new task definition
TASK_FAMILY=<task family ID>
aws ecs register-task-definition --family ${TASK_FAMILY} --cli-input-json file://task-definition-${BUILD_NUMBER}.json

# Update service
CLUSTER_NAME=<cluster name>
SERVICE_NAME=<service name>
TASK_REVISION=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY | grep revision | awk '{print $2}')
aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count 1

