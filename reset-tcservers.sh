
#docker network create tcnetwork

docker stop docker-tcserver1 docker-tcserver2
docker rm docker-tcserver1 docker-tcserver2
docker image rm tc-web-pool-12

docker build --force-rm=true --no-cache=true -t tc-web-pool-12 -f Dockerfile-webpool . 

docker run -tid \
    -p 8080:8080 -p 8081:8081 \
    --name docker-tcserver1 \
	--add-host docker-host:192.168.1.15 \
	--hostname docker-tcserver1 \
	--network tcnetwork \
    -v /opt/dockersrc/siemens/tc12.2.0.4:/apps/siemens/tc12.2.0.4 \
    -v /opt/dockersrc/siemens/tcdata:/data/tcdata \
    -v /opt/dockersrc/siemens/tclogs:/data/tclogs \
    -v /opt/dockersrc/siemens/tcapps:/apps/siemens/tcapps \
    -v /opt/dockersrc/siemens/scripts:/apps/scripts \
	tc-web-pool-12
	
docker run -tid \
    -p 8090:8080 -p 8091:8081 \
    --name docker-tcserver2 \
	--add-host docker-host:192.168.1.15 \
	--hostname docker-tcserver2 \
	--network tcnetwork \
    -v /opt/dockersrc/siemens/tc12.2.0.4:/apps/siemens/tc12.2.0.4 \
    -v /opt/dockersrc/siemens/tcdata:/data/tcdata \
    -v /opt/dockersrc/siemens/tclogs:/data/tclogs \
    -v /opt/dockersrc/siemens/tcapps:/apps/siemens/tcapps \
    -v /opt/dockersrc/siemens/scripts:/apps/scripts \
	tc-web-pool-12

