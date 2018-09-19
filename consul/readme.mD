

docker run -d --name=dev-consul -p 8446-8999:8446-8999 -e CONSUL_BIND_INTERFACE=eth0 consul

IP: eth0: 172.17.0.2

docker run -d --name=dev-consul-agent1 -e CONSUL_BIND_INTERFACE=eth0 consul agent -dev -join=172.17.0.2
docker run -d --name=dev-consul-agent2 -e CONSUL_BIND_INTERFACE=eth0 consul agent -dev -join=172.17.0.2
