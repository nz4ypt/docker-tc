

``docker-compose -f tcorcl.yml 

### 12.4.0.4 V2 update with Microservices

* run tcorcl database and populate tc12.4.0.4 schema
```
# custom containers
cd docker-tc/container
docker-compose -f tcorcl.yml up -d
docker stack deploy -c teamcenter.yml micro

# tc containers
cd $TC_ROOT/containers
docker image load -i file-repo-5.1.0.tar 
docker image load -i afx-gateway-1.4.1.tar
docker image load -i afx-darsi-1.3.0.tar
docker image load -i eureka_server-1.9.12_1.2.2.tar
docker image load -i microserviceparameterstore-1.0.0.tar
docker image load -i service_dispatcher-1.2.3.tar
docker image load -i tcgql-1.2.0.tar

for f in *.yml; do docker stack deploy -c $f micro; done

```

