# Backup & Restore for OpenShift Dev Spaces Workspace

Experiment for backup/restore of an OpenShift Dev Spaces workspace.

This project is a prototype for creating a mechanism to backup and restore the contents of a DevWorkspace PVC.

The problem that this project is trying to solve is - A cluster wide outage has occurred rendering Dev Spaces inaccessible.  Users will log into a secondary cluster and restore their workspaces to the backed up state.

## Requirements to run this prototype -

* An OpenShift 4.18+ cluster with Dev Spaces 3.23+ with User Namespaces support enabled [https://github.com/cgruver/ocp-4-18-nested-container-tech-preview](https://github.com/cgruver/ocp-4-18-nested-container-tech-preview)

* The CheCluster is assumed to be installed in the namespace `devspaces`.  Modify the install manifests if you need to change it.

* Dev Spaces users need to create a Container Registry config in their User Preferences using credentials that allow image push to the registry that is in the applied manifests at `DEVWORKSPACE_BACKUP_REGISTRY`

## Install the prototype

Modify the manifests in `backup-manifests/workspace-backup.yaml` to set the value for `DEVWORKSPACE_BACKUP_REGISTRY` and change any namespace names that don't match your installation.

```
oc apply -f backup-manifests/workspace-backup.yaml
```

This will install the following -

* A Template in the Dev Spaces namespace which will create a service account in each users namespace.

* A Template in the OpenShift Operators namespace which is used to create the backup Jobs.

* A ConfigMap in the OpenShift Operators namespace with the logic for parsing DevWorkspaces and creating backup Jobs

* A CronJob which is configured to run every 24 hours and execute the backup logic

## Workspace backup flow -

1. A CronJob runs in the namespace where the Dev Workspace Operator is installed.

1. The CronJob inspects all Dev Spaces namespaces for DevWorkspaces that have been started within a configurable amount of time.  i.e. the last 24 hours.

1. The CronJob will extract necessary metadata on the DevWorkspace to be backed up and then instantiate a Template which creates a Job in the namespace of the DevWorkspace that runs a backup routine.

1. The backup routine mounts the PVC of the DevWorkspace

1. The backup routine uses Buildah to create a FROM Scratch image containing the contents of the ${PROJECTS_ROOT} of the DevWorkspace.

1. The backup image is pushed to an external image registry using credentials within the namespace.

The backup image is named `backup-${DEVWORKSPACE_NAMESPACE}-${DEVWORKSPACE_NAME}:latest`

## Workspace Restore Flow -

1. A user that needs to recover a workspace logs into the DevSpaces dashboard on the recovery cluster.

1. The user creates a new workspace from the Git URL with the devfile for the workspace that is to be recovered.

1. After the new workspace starts, the user creates an empty file at `${PROJECTS_ROOT}/restore.workspace`

1. The user restarts the workspace which will trigger recovery from the backup container image.


```
podman build -t nexus.clg.lab:5002/dev-spaces/workspace-backup:latest ./workspace-backup-image
```

```bash
registry=nexus.clg.lab:5002/dev-spaces
workspace=dev-spaces-jupyter
namespace=cgruver-devspaces
workspace_pvc="storage-$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{.status.devworkspaceId}}')"
oc process openshift-operators//workspace-backup -p DEVWORKSPACE_BACKUP_REGISTRY=${registry} -p DEVWORKSPACE_NAME=${workspace} -p DEVWORKSPACE_NAMESPACE=${namespace} -p DEVWORKSPACE_PVC=${workspace_pvc} | oc apply -n ${namespace} -f -
```