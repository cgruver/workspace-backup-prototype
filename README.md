# workspace-backup-prototype

Experiment for backup/restore of an OpenShift Dev Spaces workspace.

```
podman build -t nexus.clg.lab:5002/dev-spaces/workspace-backup:latest ./workspace-backup-image
```

```bash
registry=nexus.clg.lab:5002/dev-spaces
workspace=dev-spaces-jupyter
namespace=cgruver-devspaces
workspace_pvc="storage-$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{.status.devworkspaceId}}')"
oc process openshift-operators//workspace-backup -p DEVWORKSPACE_BACKUP_REGISTRY=${registry} -p WORKSPACE_NAME=${workspace} -p WORKSPACE_NAMESPACE=${namespace} -p WORKSPACE_PVC=${workspace_pvc} | oc apply -n ${namespace} -f -
```