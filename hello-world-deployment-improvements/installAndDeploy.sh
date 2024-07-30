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

# Create Kubernetes deployment, service, and Pod Disruption Budget files
echo "Creating Kubernetes manifests..."

cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
spec:
  replicas: 3 # Increased replicas for higher availability
  selector:
    matchLabels:
      app: hello-world
  strategy:
    type: RollingUpdate # Use rolling update strategy
    rollingUpdate:
      maxUnavailable: 1 # Allow only 1 pod to be unavailable during updates
      maxSurge: 1 # Allow 1 additional pod to be created during updates
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: bhavinprajapti/ha-hello-world:1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: "100m" # Request minimum CPU resources
            memory: "128Mi" # Request minimum memory resources
          limits:
            cpu: "500m" # Limit maximum CPU usage
            memory: "256Mi" # Limit maximum memory usage
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10 # Wait 10 seconds before starting liveness checks
          periodSeconds: 10 # Check liveness every 10 seconds
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5 # Wait 5 seconds before starting readiness checks
          periodSeconds: 10 # Check readiness every 10 seconds
EOF

cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  type: NodePort # Use NodePort to expose service on each node's IP
  selector:
    app: hello-world
  ports:
    - protocol: TCP
      port: 80 # Expose service on port 80
      targetPort: 8080 # Forward to container port 8080
EOF

cat <<EOF > pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: hello-world-pdb
spec:
  minAvailable: 2 # Ensure at least 2 pods are available at any time
  selector:
    matchLabels:
      app: hello-world
EOF

# Apply Kubernetes configurations
echo "Applying Kubernetes configurations..."
sudo kubectl apply -f deployment.yaml
sudo kubectl apply -f service.yaml
sudo kubectl apply -f pdb.yaml

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
