# Kubernetes Multicluster Setup with Service Mesh and Monitoring

## Kubernetes
This project uses AWS Cloud Provider for building a Kubernetes cluster. It leverages following offerings from AWS:
* VPC
* Load Balancing
* EC2
* EKS
* IAM
* Route53

## IaaC
IaaC has been setup using terraform. It allows us to create, modify and delete various parts of the infrastructure.
This project has leveraged terraform modules for VPC to follow DRY principles.

## Service Mesh
Istio provides a service mesh to manage the traffic flow between various services.

## Monitoring
Prometheus is used for collecting metrics. This was chosen since istio has a native prometheus integration and it works well with kubernetes as well.
The metrics are then displayed on a grafana dashboard.
