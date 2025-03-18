#!/bin/bash
# $1: app path
# $2: app name
# $3: target path
# $4: log path
# suppose the script is run under Faaslight
# ./test-script.sh ~/serverless-app/FaaSLight-App/app2/Faaslight-App2 app2 ~/serverless-app/FaaSLight-App/app2/Faaslight-App2-modified ~/serverless-app/FaaSLight-App/app2
proj_path="/root/ServerlessPilot/"
hostip=$(hostname -I | awk '{print $1}')

cp -r $1 $3

python3 integrationFunMain.py $3
cd $3
docker build . -t $2:modified
docker tag $2:modified $hostip:5000/$2:modified
docker push $hostip:5000/$2:modified

ssh node1 "docker pull $hostip:5000/$2:modified"
ssh node1 "docker tag $hostip:5000/$2:modified $2:modified"

ssh node2 "docker pull $hostip:5000/$2:modified"
ssh node2 "docker tag $hostip:5000/$2:modified $2:modified"

ssh node3 "docker pull $hostip:5000/$2:modified"
ssh node3 "docker tag $hostip:5000/$2:modified $2:modified"

touch $4/modified.log
cd $pilot_path
python3 -m serverless_framework.controller --repeat 3 --launch tradition --transmode allTCP --ditto_placement --profile $1/$2-modified.yaml > $4/modified.log