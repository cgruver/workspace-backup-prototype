# workspace-backup-prototype

Experiment for backup/restore of an OpenShift Dev Spaces workspace.

```
podman build -t nexus.clg.lab:5002/dev-spaces/workspace-backup:latest ./workspace-backup-image
```

Test Pod -

```bash
cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: workspace-backup
spec:
  containers:
    - name: workspace-backup
      # image: quay.io/cgruver0/che/workspace-backup:latest
      image: nexus.clg.lab:5002/dev-spaces/workspace-backup:latest
      command:
        - /bin/bash
      args:
        - '-c'
        - 'tail -f /dev/null'
      env:
      - name: REGISTRY_AUTH_FILE
        value: /config/registry.auth
      volumeMounts:
      - mountPath: /workspace-pvc
        name: workspace-pvc
      - mountPath: /config
        name: registry
  restartPolicy: Never
  volumes:
    - name: workspace-pvc
      persistentVolumeClaim:
        claimName: storage-workspace7b26c4f551df4704
    - name: registry
      secret:
        secretName: devworkspace-container-registry-dockercfg
        defaultMode: 444
        items:
        - key: .dockerconfigjson
          path: registry.auth
EOF
```

```bash
export REGISTRY=nexus.clg.lab:5002/dev-spaces
export WORKSPACE_NAMESPACE=cgruver-devspaces
export WORKSPACE_NAME=che-demo-app
export WORKSPACE_ID=storage-workspace7b26c4f551df4704

```

```bash
workspace=che-demo-app
namespace=cgruver-devspaces
workspace_pvc="storage-$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{.status.devworkspaceId}}')"
oc process openshift-operators//workspace-backup -p WORKSPACE_NAME=${workspace} -p WORKSPACE_NAMESPACE=${namespace} -p WORKSPACE_PVC=${workspace_pvc} | oc apply -n ${namespace} -f -
```