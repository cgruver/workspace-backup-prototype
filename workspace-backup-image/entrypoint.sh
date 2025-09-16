#!/usr/bin/env bash

set -x
set -e

BACKUP_IMAGE=${DEVWORKSPACE_BACKUP_REGISTRY}/backup-${DEVWORKSPACE_NAMESPACE}-${DEVWORKSPACE_NAME}:latest
NEW_IMAGE=$(buildah from scratch)
buildah copy ${NEW_IMAGE} /workspace-pvc/ /
buildah config --label DEVWORKSPACE=${DEVWORKSPACE_NAME} ${NEW_IMAGE}
buildah config --label NAMESPACE=${DEVWORKSPACE_NAMESPACE} ${NEW_IMAGE}
buildah commit ${NEW_IMAGE} ${BACKUP_IMAGE}
buildah umount ${NEW_IMAGE}
buildah push ${BACKUP_IMAGE}
