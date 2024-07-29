#!/bin/bash

# Install K3s if it's not already installed
if ! command -v k3s &>/dev/null; then
  echo "Installing K3s..."
  curl -sfL https://get.k3s.io | sh -
else
  echo "K3s is already installed."
fi

# Verify K3s installation
echo "Verifying K3s installation..."
if sudo kubectl get nodes; then
  echo "K3s installed and running successfully."
else
  echo "Failed to install or start K3s."
  exit 1
fi

# Create Kubernetes deployment and service files
echo "Creating Kubernetes manifests..."

cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: bhavinprajapti/hello-world-go:1.0
        ports:
        - containerPort: 8080
EOF

cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  type: NodePort
  selector:
    app: hello-world
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF

# Apply Kubernetes configurations
echo "Applying Kubernetes configurations..."
sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f service.yaml

# Wait for the deployment to be ready
echo "Waiting for the deployment to be ready..."
if sudo kubectl wait --for=condition=available deployment/hello-world-deployment --timeout=300s; then
  echo "Deployment is available and ready."
else
  echo "Deployment failed to become ready within the timeout period."
  exit 1
fi

# Wait for the pods to be ready
echo "Waiting for the pods to be ready..."
if sudo kubectl wait --for=condition=ready pod -l app=hello-world --timeout=300s; then
  echo "All pods are ready and running successfully."
else
  echo "Pods failed to become ready within the timeout period."
  exit 1
fi

# Get the NodePort
NODE_PORT=$(sudo kubectl get svc hello-world-service -o=jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(hostname -I | awk '{print $1}')

# Curl the application
echo "Curling the application at http://$NODE_IP:$NODE_PORT"
curl http://$NODE_IP:$NODE_PORT

echo -e " "
