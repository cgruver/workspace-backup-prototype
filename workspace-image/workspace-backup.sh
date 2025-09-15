
#!/usr/bin/env bash

BACKUP_IMAGE=${WORKSPACE_REGISTRY}/backup-${DEVWORKSPACE_NAMESPACE}-${DEVWORKSPACE_NAME}:latest
NEW_IMAGE=$(buildah from scratch)
buildah copy ${NEW_IMAGE} /${PROJECTS_ROOT}/ /
buildah config --label WORKSPACE_ID=${WORKSPACE_ID} ${NEW_IMAGE}
buildah commit ${NEW_IMAGE} ${BACKUP_IMAGE}
buildah umount ${NEW_IMAGE}
buildah push ${BACKUP_IMAGE}

