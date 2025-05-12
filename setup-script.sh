#!/bin/bash

# Setup script for Google Cloud Artifact Registry lab
# This script sets up the necessary components for working with
# Artifact Registry, including Docker repositories and GKE clusters

# Exit on error
set -e

# Check if required tools are installed
if ! command -v gcloud &>/dev/null; then
  echo "Error: gcloud CLI is not installed. Please install it."
  exit 1
fi

if ! command -v docker &>/dev/null; then
  echo "Error: Docker is not installed. Please install it."
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "Error: Git is not installed. Please install it."
  exit 1
fi

# Get user input for region and zone
read -p "Enter your Google Cloud region (e.g., us-central1): " REGION
read -p "Enter your Google Cloud zone (e.g., us-central1-a): " ZONE

# Set up environment variables
echo "Setting up environment variables..."
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=$REGION
gcloud config set compute/region $REGION

echo "Project ID: $PROJECT_ID"
echo "Project Number: $PROJECT_NUMBER"
echo "Region: $REGION"
echo "Zone: $ZONE"

# Enable required Google services
echo "Enabling required Google services..."
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  containerregistry.googleapis.com \
  containerscanning.googleapis.com

# Create a GKE cluster
echo "Creating GKE cluster container-dev-cluster..."
gcloud container clusters create container-dev-cluster --zone=$ZONE

# Create a Docker repository in Artifact Registry
echo "Creating Docker repository in Artifact Registry..."
gcloud artifacts repositories create container-dev-repo --repository-format=docker \
  --location=$REGION \
  --description="Docker repository for Container Dev Workshop"

# Configure Docker authentication
echo "Configuring Docker authentication..."
gcloud auth configure-docker "$REGION-docker.pkg.dev"

# Create a Java package repository in Artifact Registry
echo "Creating Java package repository in Artifact Registry..."
gcloud artifacts repositories create container-dev-java-repo \
  --repository-format=maven \
  --location=$REGION \
  --description="Java package repository for Container Dev Workshop"

# Set up authentication for Artifact Registry
echo "Setting up authentication for Artifact Registry..."
gcloud auth login --update-adc

# Clone the sample application
echo "Cloning sample application..."
git clone https://github.com/GoogleCloudPlatform/cloud-code-samples/
cd cloud-code-samples/java/java-hello-world

# Print Maven configuration
echo "Maven configuration for Artifact Registry:"
gcloud artifacts print-settings mvn \
  --repository=container-dev-java-repo \
  --location=$REGION

echo "Setup complete! You can now follow the instructions in the README.md file to continue with the lab."
