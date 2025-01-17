#!/bin/bash

# Variables
ACR_NAME="youracrname"
ECR_ACCOUNT="awsaccount"
ECR_REGION="eu-west-1"
IMAGE_LIST="images.txt"

# Read image list file
while IFS= read -r IMAGE_NAME; do
    # Split image name into repository and tag
    IFS=':' read -r REPOSITORY TAG <<< "$IMAGE_NAME"

    # Create repository in ECR if it doesn't exist
    aws ecr describe-repositories --repository-names "$REPOSITORY" --region "$ECR_REGION" || \
    aws ecr create-repository --repository-name "$REPOSITORY" --region "$ECR_REGION"

    # Define ACR and ECR full image names
    ACR_IMAGE="$ACR_NAME.azurecr.io/$IMAGE_NAME"
    ECR_IMAGE="$ECR_ACCOUNT.dkr.ecr.$ECR_REGION.amazonaws.com/$IMAGE_NAME"

    # Copy image from ACR to ECR using skopeo
    skopeo copy --src-tls-verify=false --dest-tls-verify=false "docker://$ACR_IMAGE" "docker://$ECR_IMAGE"
done < "$IMAGE_LIST"

echo "All images have been successfully copied."
