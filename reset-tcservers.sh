#!/bin/bash

#docker network create tcnetwork

docker stop docker-tcserver1 docker-tcserver2
docker rm docker-tcserver1 docker-tcserver2
docker image rm tc-web-pool-12

docker build --force-rm=true --no-cache=true -t tc-web-pool-12 -f Dockerfile-webpool . 

# publish 8080 is optional if behind load balancer
# 8081 (jmx) optional

HOST_IP=192.168.1.15
# number of TCServer
SRV=2

for i in $(seq $SRV); do 
    docker run -tid \
        -p 808$i:8080 -p 900$i:8081 \
        --name docker-tcserver$i \
        --add-host docker-host:$HOST_IP \
        --hostname docker-tcserver$i \
        --network tcnetwork \
        -v /opt/dockersrc/siemens/tc12.2.0.4:/apps/siemens/tc12.2.0.4 \
        -v /opt/dockersrc/siemens/tcdata:/data/tcdata \
        -v /opt/dockersrc/siemens/tclogs:/data/tclogs \
        -v /opt/dockersrc/siemens/tcapps:/apps/siemens/tcapps \
        -v /opt/dockersrc/siemens/scripts:/apps/scripts \
        tc-web-pool-12
done

