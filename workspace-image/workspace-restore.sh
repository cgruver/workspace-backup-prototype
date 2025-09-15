#!/usr/bin/env bash

BACKUP_IMAGE=${WORKSPACE_REGISTRY}/backup-${DEVWORKSPACE_NAMESPACE}-${DEVWORKSPACE_NAME}:latest
podman create --name workspace-restore ${BACKUP_IMAGE}
rm -rf ${PROJECTS_ROOT}
mkdir -p ${PROJECTS_ROOT}
podman cp workspace-restore:/ ${PROJECTS_ROOT}
