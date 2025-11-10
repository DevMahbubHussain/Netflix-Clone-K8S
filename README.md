# Netflix-Clone-K8S
Netflix Clone - DevOPS Project


TF_API_TOKEN
TF_WORKSPACE
TF_CLOUD_ORGANIZATION


AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

ssh-keygen -t rsa -b 4096 -f web_key -N ""


### Install Dokcer and Docker Compose 
sudo apt update -y
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

Check versions:

docker --version
docker-compose --version


Jenkins – CI/CD automation server

SonarQube – Code quality analysis tool

Trivy – Vulnerability scanner

PostgreSQL – Database for SonarQube
All orchestrated with Docker Compose.