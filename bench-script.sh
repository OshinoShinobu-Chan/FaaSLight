#!/bin/bash
# $1: app path
# $2: app name
# $3: log path
# ./bench-script.sh ~/serverless-app/FaaSLight-App/app2/Faaslight-App2 app2 ~/serverless-app/FaaSLight-App/app2
proj_path="/root/ServerlessPilot"
hostip=$(hostname -I | awk '{print $1}')

cd $1
docker build . -t $2:origin 
docker tag $2:origin $hostip:5000/$2:origin
docker push $hostip:5000/$2:origin

ssh node1 "docker pull $hostip:5000/$2:origin"
ssh node1 "docker tag $hostip:5000/$2:origin $2:origin"

ssh node2 "docker pull $hostip:5000/$2:origin"
ssh node2 "docker tag $hostip:5000/$2:origin $2:origin"

ssh node3 "docker pull $hostip:5000/$2:origin"
ssh node3 "docker tag $hostip:5000/$2:origin $2:origin"

touch $3/origin.log
cd $pilot_path
python3 -m serverless_framework.controller --repeat 3 --launch tradition --transmode allTCP --ditto_placement --profile $1/$2-origin.yaml > $3/origin.log