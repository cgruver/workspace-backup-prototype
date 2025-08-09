#!/usr/bin/env bash

BACKUP_IMAGE=${REGISTRY}/backup-${WORKSPACE_NAMESPACE}-${WORKSPACE_NAME}-${WORKSPACE_ID}:latest
NEW_IMAGE=$(buildah from scratch)
# MNT_POINT=$(buildah mount ${NEW_IMAGE})
# rsync -avP /workspace-pvc/ ${MNT_POINT}/ --delete

buildah copy ${NEW_IMAGE} /workspace-pvc/ /
buildah config --label WORKSPACE_ID=${WORKSPACE_ID} ${NEW_IMAGE}
buildah commit ${NEW_IMAGE} ${BACKUP_IMAGE}
buildah umount ${NEW_IMAGE}
buildah push ${BACKUP_IMAGE}
