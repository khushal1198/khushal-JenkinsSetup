#!/bin/bash

# Build the Docker image
echo "Building Docker image..."
docker build -t hello-grpc:latest .

# Save the image to a tar file
echo "Saving Docker image..."
docker save hello-grpc:latest > hello-grpc.tar

# Copy the image to the server
echo "Copying image to server..."
scp hello-grpc.tar khushal@10.0.0.100:~/hello_grpc/

# Load and run the image on the server
echo "Loading and running image on server..."
ssh khushal@10.0.0.100 "cd ~/hello_grpc && \
    docker load < hello-grpc.tar && \
    docker stop hello-grpc || true && \
    docker rm hello-grpc || true && \
    docker run -d --name hello-grpc -p 50051:50051 hello-grpc:latest"

# Clean up
echo "Cleaning up..."
rm hello-grpc.tar

echo "Deployment complete!" 