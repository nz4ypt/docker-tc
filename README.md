

### Teamcenter 12 in Docker


> **Note** This is still pretty rough and require being creative here or there to really set it up. It also requires decent understanding about Teamcenter Unified Architecture. 

* Oracle 18c image with TC schema populated
 
Docker Image: donggonghua/oracle-tc12-orcl


* TcFMS and License (Dockerfile-webpool)
  - Teamcenter FMS Master
  - Siemens PLM License server (Optional)

* TcServer container (Dockerfile-fmslic)
  - Tomcat 8.5.57 Application Server
  - Teamcenter Pool Manager TCP mode
  - FSC Slave to support server pool

* TcLB
  - Nginx simple load balancer, to support multiple TcServer containers.
  - 

```shell
docker run -tid \
    -p 80:80 \
    --name docker-tclb \
	--add-host docker-host:your-host-ip \
	--hostname docker-tclb \
	--network tcnetwork \
	nginx
```


```shell
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
 





