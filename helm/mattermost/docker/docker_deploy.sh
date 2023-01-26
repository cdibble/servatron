#!/bin/bash
TAG=mattermost_piv0.0
ENV=PI
# DOCKER_BUILDKIT=1 docker build --ssh github_ssh_key=~/.ssh/id_ed25519 -f Dockerfile -t $TAG --build-arg ENV=$ENV --platform linux/amd64 .

DOCKER_BUILDKIT=1 docker build -f Dockerfile -t $TAG --build-arg ENV=$ENV --platform linux/amd64 .