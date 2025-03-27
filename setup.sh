# Random comands I need to run to quickly setup stuff once k3d explodes again...


k3d cluster delete mycluster
docker kill $(docker ps -q)

k3d cluster create mycluster

helm repo add strimzi https://strimzi.io/charts
helm repo add spark-operator https://kubeflow.github.io/spark-operator
helm repo update


# Install the operators
helm install my-strimzi-kafka-operator strimzi/strimzi-kafka-operator --version 0.45.0 --wait
helm install spark-operator spark-operator/spark-operator --namespace spark-operator --create-namespace --wait



# For test purposes
kubectl apply -f https://raw.githubusercontent.com/kubeflow/spark-operator/refs/heads/master/examples/spark-pi.yaml





k apply -f ./wednesday/mongodb.yaml
k apply -f ./wednesday/minio.yaml


k apply -f ./thursday/kafka-persistent-single.yaml

# Setup all your ports
k port-forward svc/minio 9000 9001
k port-forward svc/mongodb-service 27017
k port-forward pods/my-cluster-kafka-0 9092 9093

# WARNING - don't forget to set up neo4j in the desktop app 

# Need to find the service name for the kafka service (my-cluster-kafka-0.my-cluster-kafka-brokers.default.svc)


