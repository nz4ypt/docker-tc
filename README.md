

## Teamcenter 12 in Docker


> **Note** This is still pretty rough and require being creative here or there to really set it up. It also requires decent understanding about Teamcenter Unified Architecture. 

#### Oracle 18c image with TC schema populated
 
Docker Image: [donggonghua/oracle-tc12-orcl](https://hub.docker.com/repository/docker/donggonghua/oracle-tc12-orcl)

```shell
docker pull donggonghua/oracle-tc12-orcl:firsttry

docker run -d -p 1521:1521 -p 5500:5500 \
    --name docker-tcorcl \
    -e ORACLE_SID=TCORCL \
    -e ORACLE_PDB=TCORCLP1 \
    -e ORACLE_PWD=tcorcl \
    -v /your-gitroot/docker-tc/oracle/startup:/opt/oracle/scripts/startup \
    donggonghua/oracle-tc12-orcl

```


#### TcFMS and License 
  - Teamcenter FMS Master
  - Siemens PLM License server (Optional)
 
> Docker File: `Dockerfile-fmslic`

```shell
docker build --force-rm=true --no-cache=true -t tc-fms-lic-12 -f Dockerfile-fmslic .

# Static port for vendor daemon used (28001)
docker run -tid \
	-p 4544:4544 \
    -p 28000:28000 -p 28001:28001 \
    --name docker-fmslic \
	--network tcnetwork \
	--add-host docker-host:your-host-ip \
	--hostname docker-fmslic \
	-e FSC_HOME=/apps/siemens/tc12.2.0.4/fsc \
    -v /opt/dockersrc/siemens/tc12.2.0.4:/apps/siemens/tc12.2.0.4 \
    -v /opt/dockersrc/siemens/tclogs:/data/tclogs \
    -v /opt/dockersrc/siemens/tcvols:/data/tcvols \
	tc-fms-lic-12
```

#### TcServer container
  - Tomcat 8.5.57 Application Server
  - Teamcenter Pool Manager TCP mode
  - FSC Slave to support server pool

> Docker File: `Dockerfile-webpool`

```shell
docker build --force-rm=true --no-cache=true -t tc-web-pool-12 -f Dockerfile-webpool .

# Publish tomcat port is optional if load balancer is used below.
# 8081 used for JMX which is optional
docker run -tid \
    -p 8080:8080 -p 8081:8081 \
    --name docker-tcserver1 \
	--add-host docker-host:your-host-ip \
	--hostname docker-tcserver1 \
	--network tcnetwork \
    -v /opt/dockersrc/siemens/tc12.2.0.4:/apps/siemens/tc12.2.0.4 \
    -v /opt/dockersrc/siemens/tcdata:/data/tcdata \
    -v /opt/dockersrc/siemens/tclogs:/data/tclogs \
    -v /opt/dockersrc/siemens/tcapps:/apps/siemens/tcapps \
    -v /opt/dockersrc/siemens/scripts:/apps/scripts \
	tc-web-pool-12
```

#### Tc Load Balaner
  - Nginx simple load balancer, to support multiple TcServer containers.

```shell
docker run -tid \
    -p 80:80 \
    --name docker-tclb \
	--add-host docker-host:your-host-ip \
	--hostname docker-tclb \
	--network tcnetwork \
	nginx

docker start docker-tclb 
docker exec -it docker-tclb bash

cat << EOF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}
http {
    upstream backend {
        least_conn;
        server docker-tcserver1:8080;
        server docker-tcserver2:8080;
        #server docker-tcserver3:8080 backup;
        #server docker-tcserver4:8080 backup;
        #server docker-tcserver5:8080 backup;
    }
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}
EOF

exit
docker restart docker-tclb
```
 
#### Screenshots

* Docker containers

![docker-tc containers](https://1.bp.blogspot.com/-xnXC7mfX5KI/Xy7Hex9NaPI/AAAAAAAAESI/6oQdj4hxJygwGSFBvpPa7GlHrcRMo0LQwCLcBGAsYHQ/s640/tc-docker.png)

* Active Workspace (Load Balancer)

![AWC](https://1.bp.blogspot.com/-K0jVXT5cw5c/Xy7HtF1WPyI/AAAAAAAAESM/fiil-UvDvXo6-83olWBMW_EKnHt3kKH3QCLcBGAsYHQ/s640/docker-tc-lb-awc.png)










