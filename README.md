

### Teamcenter 12 in Docker


> **Note** This is still pretty rough and require being creative here or there to really set it up. It also requires decent understand about Teamcenter Unified Architecture. 

* Oracle 18c image with TC schema populated
 
Docker Image: donggonghua/oracle-tc12-orcl


* TcFMS and License
  - Teamcenter FMS Master
  - Siemens PLM License server (Optional)

* TcServer container
  - Tomcat 8.5.57 Application Server
  - Teamcenter Pool Manager TCP mode
  - FSC Slave to support server pool

* TcLB
  - Nginx simple load balancer, to support multiple TcServer containers.





