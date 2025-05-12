# Working with Google Cloud Artifact Registry

This repository contains a step-by-step guide for working with Google Cloud Artifact Registry, based on a hands-on lab I completed. It shows how to create repositories for containers and language packages, manage container images, integrate with Cloud Code, and configure Maven for Java dependencies.

## Overview

Google Cloud Artifact Registry is the evolution of Container Registry, providing a single place to manage container images and language packages (Maven, npm, etc.). It integrates with Google Cloud's tooling and runtimes and supports native artifact protocols, making it easy to set up automated CI/CD pipelines.

## Prerequisites

- Google Cloud account with billing enabled
- Basic knowledge of Docker, containers, and Java development
- gcloud CLI installed
- Docker installed
- Git installed

## Video

https://youtu.be/XkzftqMg8Uc


## Setup

### Set Environment Variables

```bash
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION="YOUR_REGION"
gcloud config set compute/region $REGION
```

### Enable Required Google Services

```bash
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  containerregistry.googleapis.com \
  containerscanning.googleapis.com
```

### Create a GKE Cluster

```bash
gcloud container clusters create container-dev-cluster --zone="YOUR_ZONE"
```

## Working with Container Images

### Create a Docker Repository

```bash
gcloud artifacts repositories create container-dev-repo --repository-format=docker \
  --location=$REGION \
  --description="Docker repository for Container Dev Workshop"
```

### Configure Docker Authentication

```bash
gcloud auth configure-docker "$REGION-docker.pkg.dev"
```

### Build and Push a Container Image

Clone the sample application:
```bash
git clone https://github.com/GoogleCloudPlatform/cloud-code-samples/
cd cloud-code-samples/java/java-hello-world
```

Build the container image:
```bash
docker build -t "$REGION-docker.pkg.dev/$PROJECT_ID/container-dev-repo/java-hello-world:tag1" .
```

Push the image to Artifact Registry:
```bash
docker push "$REGION-docker.pkg.dev/$PROJECT_ID/container-dev-repo/java-hello-world:tag1"
```

## Integration with Cloud Code

### Deploy to GKE from Cloud Code

1. Open Cloud Shell Editor:
   ```bash
   cd ~/cloud-code-samples/
   cloudshell workspace .
   ```

2. From the Cloud Code extension, select "Run on Kubernetes"
3. Choose `cloud-code-samples/java/java-hello-world/skaffold.yaml` and then `dockerfile`
4. When prompted for image registry, enter your Artifact Registry repository location:
   ```
   $REGION-docker.pkg.dev/$PROJECT_ID/container-dev-repo
   ```

### Update Application Code

1. Open `src/main/java/cloudcode/helloworld/web/HelloWorldController.java`
2. Update the text in the application to see changes deployed automatically

## Working with Language Packages

### Create a Java Package Repository

```bash
gcloud artifacts repositories create container-dev-java-repo \
    --repository-format=maven \
    --location="$REGION" \
    --description="Java package repository for Container Dev Workshop"
```

### Set up Authentication for Artifact Registry

```bash
gcloud auth login --update-adc
```

### Configure Maven for Artifact Registry

Get Maven configuration:
```bash
gcloud artifacts print-settings mvn \
    --repository=container-dev-java-repo \
    --location="$REGION"
```

Add the required configurations to your `pom.xml`:

```xml
<!-- Add distributionManagement section -->
<distributionManagement>
  <snapshotRepository>
    <id>artifact-registry</id>
    <url>artifactregistry://$REGION-maven.pkg.dev/$PROJECT_ID/container-dev-java-repo</url>
  </snapshotRepository>
  <repository>
    <id>artifact-registry</id>
    <url>artifactregistry://$REGION-maven.pkg.dev/$PROJECT_ID/container-dev-java-repo</url>
  </repository>
</distributionManagement>

<!-- Add repositories section -->
<repositories>
  <repository>
    <id>artifact-registry</id>
    <url>artifactregistry://$REGION-maven.pkg.dev/$PROJECT_ID/container-dev-java-repo</url>
    <releases>
      <enabled>true</enabled>
    </releases>
    <snapshots>
      <enabled>true</enabled>
    </snapshots>
  </repository>
</repositories>

<!-- Add extensions in build section -->
<extensions>
  <extension>
    <groupId>com.google.cloud.artifactregistry</groupId>
    <artifactId>artifactregistry-maven-wagon</artifactId>
    <version>2.1.0</version>
  </extension>
</extensions>
```

### Deploy Java Package to Artifact Registry

```bash
cd ~/cloud-code-samples/java/java-hello-world
mvn deploy
```

## Key Files in this Repository

- `README.md` - This file with detailed instructions
- `pom.xml` - Sample Maven configuration for Artifact Registry
- `Dockerfile` - Sample Dockerfile for building the Java application
- `skaffold.yaml` - Configuration for Cloud Code and Kubernetes deployment
- `setup.sh` - Setup script with all required commands

## Screenshots

- `images/artifact-registry-repositories.png` - Screenshot of Artifact Registry repositories
- `images/vulnerability-scanning.png` - Screenshot of vulnerability scanning results
- `images/cloud-code-deployment.png` - Screenshot of Cloud Code deployment
- `images/java-repository.png` - Screenshot of Java artifacts in Artifact Registry

## References

- [Google Cloud Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)
- [Cloud Code Documentation](https://cloud.google.com/code/docs)
- [Google Kubernetes Engine Documentation](https://cloud.google.com/kubernetes-engine/docs)
