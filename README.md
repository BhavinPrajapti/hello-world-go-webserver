# hello-world-go-webserver

## Overview

This project demonstrates a self-contained deployment of a simple Go web server that responds with "Hello World" to HTTP requests. The solution uses Docker for containerization and adheres to infrastructure-as-code principles, ensuring the deployment is reusable and consistent across different environments. Additionally, the project includes Kubernetes configuration files for deploying the web server in a Kubernetes cluster and accessing it outside the cluster.

## Project Structure

```
hello-world-webserver/
├── Dockerfile       # Dockerfile for building the Docker image
├── README.md        # Documentation file
├── app/
│   ├── main.go      # Go source code for the web server
│   ├── go.mod       # The Go module file that manages dependencies
├── k8s/
│   ├── deployment.yaml  # Kubernetes Deployment file
│   └── service.yaml     # Kubernetes Service file
```

## Prerequisites

To build and run this project, you need the following software installed on your Unix-based system:

- **Docker**: Ensure Docker is installed and running on your machine. You can download it from [Docker's official website](https://www.docker.com/get-started).

## Setup

1. Clone the repository or copy the files into a directory on your local machine.
2. Navigate to the project directory.

### Build the Docker Image

Build the Docker image using the following command:

```sh
docker build -t hello-world .
```

### Run the Docker Container

Run the Docker container using the following command:

```sh
docker run -p 8080:8080 hello-world
```
This command maps port 8080 on your host machine to port 8080 in the container, making the web server accessible from your browser or any HTTP client.

i already built and push this image to my refistry. you can also run container by following commands:

for pulling image from my registry

```sh
docker pull bhavinprajapti/hello-world-go:1.0
```
```sh
docker run -p 8080:8080 bhavinprajapti/hello-world-go:1.0
```

### Access the Web Server

Once the container is running, access the web server by navigating to the following URL in your web browser:

```
http://localhost:8080
```

You should see the message "Hello World" displayed.


### Option: Use Pre-built Image from Docker Hub

Alternatively, you can use the pre-built image that has already been pushed to my registry. Follow these commands:

To pull the image from my Docker Hub registry, use the following command:

```sh
docker pull bhavinprajapti/hello-world-go:1.0
```

Run the Docker container using the image pulled from the registry with the following command:

```sh
docker run -p 8080:8080 bhavinprajapti/hello-world-go:1.0
```

## Additional Deployment with Kubernetes

In addition to running the web server in Docker, you can deploy it on a Kubernetes cluster. Below are the steps to do so.

### Prerequisites for Kubernetes Deployment

- Kubernetes cluster set up (local or cloud-based).
- `kubectl` configured to interact with your Kubernetes cluster.

### Push Docker Image to Docker Hub

Ensure the Docker image is pushed to Docker Hub so that it can be pulled by Kubernetes nodes.

```sh
docker tag hello-world:latest <your-docker-repo>/hello-world-go:1.0
docker push <your-docker-repo>/hello-world-go:1.0
```

### Apply Kubernetes Configurations

Navigate to the `k8s` directory:

```sh
cd k8s
```

Apply the deployment and service configurations:

```sh
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### Access the Web Server

Once the service is created, it will provision an external IP address. You can get the external IP using:

```sh
kubectl get services
```

Look for the `EXTERNAL-IP` column for the `hello-world-service` service. Open your web browser and navigate to the external IP. You should see "Hello World" displayed.

