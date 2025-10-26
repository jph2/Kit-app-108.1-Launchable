#!/bin/bash
echo "BREV SCRIPT STARTED: $(date)" > /home/ubuntu/brev-setup.log
git clone -b Work_A https://github.com/jph2/Kit-app-108.1-Launchable.git >> /home/ubuntu/brev-setup.log 2>&1
echo "GIT CLONE COMPLETED: $(date)" >> /home/ubuntu/brev-setup.log
cd Kit-app-108.1-Launchable/kit-app-108
echo "STARTING DOCKER-COMPOSE: $(date)" >> /home/ubuntu/brev-setup.log
docker-compose up -d >> /home/ubuntu/brev-setup.log 2>&1
echo "DOCKER-COMPOSE COMPLETED: $(date)" >> /home/ubuntu/brev-setup.log

